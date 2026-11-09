#' knitr engine for embedding rendered tags as iframes
#'
#' This engine is registered as `tagframe` (and `bslib` as an alias) when the
#' package is loaded, so a chunk written as ```` ```{tagframe} ```` is handled
#' by it. The chunk code is evaluated in a child of the knitting environment,
#' so objects and attached packages from earlier R chunks are visible. The
#' value of the last expression must be an htmltools tag, tag list, or
#' htmlwidget. It is wrapped in a [bslib::page()] (unless it already is a
#' bslib page), written to `<dir>/<label>.html` with its dependencies copied
#' to a shared `<dir>/lib/` folder, and an `<iframe>` pointing at that file is
#' emitted in place of the chunk output.
#'
#' Supported chunk options (in addition to the usual knitr ones such as
#' `echo`, `label`, and Quarto's `output-location`):
#'
#' * `height`, `width`: iframe size, a CSS unit or a number of pixels.
#'   Defaults are `"100%"`.
#' * `theme`: R code (as a string) evaluating to a [bslib::bs_theme()], used
#'   when wrapping a non-page result. Defaults to `getOption("tagframe.theme")`
#'   or `bslib::bs_theme()`.
#' * `title`: the page title.
#' * `lazy`: if `TRUE` the iframe is written with `data-src` and
#'   `data-preload` so reveal.js loads it only as the slide comes into view.
#'   The default (`FALSE`) uses a plain `src` attribute, which is needed for
#'   the frame to appear when the deck is printed to PDF.
#'
#' The output directory is `getOption("tagframe.dir")` if set, otherwise
#' `<input>_frames/` next to the document being knitted. The first time the
#' engine writes to a directory in a session it removes any `.html` files
#' already there so that renamed or deleted chunks do not leave stale pages
#' behind (`getOption("tagframe.clean", TRUE)` controls this).
#'
#' @param options A list of chunk options, as passed by knitr.
#'
#' @return A character string of knitted output, as returned by
#'   [knitr::engine_output()].
#'
#' @examples
#' \dontrun{
#' # In a Quarto document, after library(tagframe) in a setup chunk:
#' # ```{tagframe}
#' # #| height: 200
#' # bslib::card(bslib::card_header("A header"), "Some text")
#' # ```
#' }
#'
#' @export
eng_tagframe = function(options) {
  code = paste(options$code, collapse = "\n")
  env = new.env(parent = knitr::knit_global())

  result = withCallingHandlers(
    eval(parse(text = code, keep.source = FALSE), envir = env),
    message = function(m) invokeRestart("muffleMessage")
  )

  if (!is_renderable(result)) {
    stop(
      "The last expression of a tagframe chunk must return an htmltools tag, ",
      "tag list, or htmlwidget, not an object of class <",
      paste(class(result), collapse = "/"), ">.",
      call. = FALSE
    )
  }

  theme = options$theme
  if (is.character(theme)) {
    theme = eval(parse(text = theme, keep.source = FALSE), envir = env)
  }
  theme = theme %||% getOption("tagframe.theme") %||% bslib::bs_theme()

  page = if (inherits(result, "bslib_page")) {
    result
  } else {
    bslib::page(result, title = options$title, theme = theme)
  }

  dir = frame_dir()
  prepare_dir(dir)
  file = file.path(dir, paste0(options$label, ".html"))
  htmltools::save_html(page, file = file, libdir = "lib")

  out = frame_tag(
    src = file,
    width = options$width %||% "100%",
    height = options$height %||% "100%",
    lazy = options$lazy %||% getOption("tagframe.lazy", FALSE)
  )

  options$results = "asis"
  options$engine = "r"
  knitr::engine_output(options, options$code, as.character(out))
}

is_renderable = function(x) {
  inherits(x, c("shiny.tag", "shiny.tag.list", "htmlwidget", "html"))
}

frame_dir = function() {
  dir = getOption("tagframe.dir")
  if (is.null(dir)) {
    input = knitr::current_input()
    base = if (is.null(input)) "tagframe" else tools::file_path_sans_ext(input)
    dir = paste0(base, "_frames")
  }
  dir
}

cleaned = new.env(parent = emptyenv())

prepare_dir = function(dir) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  key = normalizePath(dir)
  if (isTRUE(getOption("tagframe.clean", TRUE)) && !isTRUE(cleaned[[key]])) {
    unlink(list.files(dir, pattern = "\\.html$", full.names = TRUE))
    cleaned[[key]] = TRUE
  }

  invisible(dir)
}

frame_tag = function(src, width, height, lazy) {
  width = htmltools::validateCssUnit(width)
  height = htmltools::validateCssUnit(height)

  src_attrs = if (isTRUE(lazy)) {
    list(`data-src` = src, `data-preload` = NA)
  } else {
    list(src = src)
  }

  rlang::inject(
    htmltools::tags$iframe(
      !!!src_attrs,
      width = width,
      height = height,
      style = "border: none;",
      scrolling = "no",
      `data-external` = "1"
    )
  )
}
