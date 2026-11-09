# tagframe

A small knitr engine for embedding rendered htmltools content (`bslib` components, htmlwidgets, Shiny UI elements) in Quarto slides.

Bootstrap and reveal.js do not share a page gracefully, so each chunk is rendered to its own standalone HTML page and shown in the slide through an iframe. The engine does this directly with `htmltools::save_html()`, so there is no per-chunk `quarto render`, no template file, and the deck's setup chunk only needs `library(tagframe)`.

## Usage

```r
library(tagframe)
```

in a setup chunk registers the `tagframe` engine (and `bslib` as an alias). Then

````
```{bslib}
#| height: 250
#| output-location: column
card(
  card_header("A header"),
  card_body("Some text")
)
```
````

evaluates the code, wraps the result in `bslib::page()`, writes it to `<input>_frames/<label>.html` with dependencies in `<input>_frames/lib/`, and emits an iframe pointing at that file. Objects and packages from earlier R chunks are visible to the chunk.

Chunk options: `height`, `width` (CSS units or pixels), `theme` (R code for a `bs_theme()`), `title`, `lazy` (load via reveal.js `data-src` only when the slide is near, default `FALSE` since lazy frames do not appear in the printed PDF).

Global options: `tagframe.dir` (output directory), `tagframe.theme` (default theme), `tagframe.lazy` (default for `lazy`), `tagframe.clean` (remove existing `.html` files from the output directory on first use, default `TRUE`).

`anim_width()` and `anim_height()` animate a tag between two sizes, for demonstrating responsive layouts.

## Installing

From the website repo root:

```sh
R CMD INSTALL tagframe
```

The frames directory must be published alongside the slide HTML (Hugo copies everything under `static/slides/`, so this happens automatically).
