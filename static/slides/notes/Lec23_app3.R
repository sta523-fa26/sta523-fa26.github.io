library(tidyverse)
library(shiny)
library(bslib)

prior_ui = function(id, label) {
  ns = NS(id)

  card(
    id = ns("card"),
    card_header(
      label,
      actionButton(
        ns("remove"), NULL, icon = icon("xmark"),
        class = "btn-sm btn-outline-danger"
      ),
      class = "d-flex justify-content-between align-items-center"
    ),
    numericInput(ns("a"), "Prior # of heads", min = 0, value = 1),
    numericInput(ns("b"), "Prior # of tails", min = 0, value = 1)
  )
}

prior_server = function(id, label, x, n) {
  moduleServer(id, function(input, output, session) {
    removed = reactiveVal(FALSE)

    observe({
      removeUI(paste0("#", session$ns("card")))
      removed(TRUE)
    }) |>
      bindEvent(input$remove, once = TRUE)

    reactive({
      if (removed()) return(NULL)
      req(input$a, input$b)

      tibble(
        prior = label,
        p = seq(0, 1, length.out = 501),
        density = dbeta(p, input$a + x(), input$b + n() - x())
      )
    })
  })
}

ui = page_sidebar(
  title = "Beta-Binomial Prior Comparison",
  sidebar = sidebar(
    width = 300,
    sliderInput("x", "# of heads", min = 0, max = 100, value = 7),
    sliderInput("n", "# of flips", min = 0, max = 100, value = 10),
    actionButton("add", "Add prior", class = "btn-primary"),
    div(id = "priors")
  ),
  card(
    card_header("Posteriors"),
    plotOutput("plot")
  )
)

server = function(input, output, session) {
  observe({
    updateSliderInput(session, "x", max = input$n)
  }) |>
    bindEvent(input$n)

  priors = reactiveVal(list())

  observe({
    id = paste0("prior_", input$add)
    label = paste("Prior", input$add)

    insertUI("#priors", where = "beforeEnd", ui = prior_ui(id, label))
    prior = prior_server(id, label, x = reactive(input$x), n = reactive(input$n))
    priors(c(priors(), prior))
  }) |>
    bindEvent(input$add)

  d = reactive({
    map(priors(), \(prior) prior()) |>
      list_rbind()
  })

  output$plot = renderPlot({
    req(nrow(d()) > 0)

    ggplot(d(), aes(x = p, y = density, color = prior)) +
      geom_line(linewidth = 1.5) +
      labs(color = NULL)
  })
}

shinyApp(ui = ui, server = server)
