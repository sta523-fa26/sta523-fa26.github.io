library(tidyverse)
library(shiny)
library(bslib)

prior_card = function(id) {
  card(
    card_header(paste("Prior", id)),
    numericInput(paste0("a_", id), "Prior # of heads", min = 0, value = 1),
    numericInput(paste0("b_", id), "Prior # of tails", min = 0, value = 1)
  )
}

ui = page_sidebar(
  title = "Beta-Binomial Prior Comparison",
  sidebar = sidebar(
    width = 300,
    sliderInput("x", "# of heads", min = 0, max = 100, value = 7),
    sliderInput("n", "# of flips", min = 0, max = 100, value = 10),
    actionButton("add", "Add prior", class = "btn-primary"),
    uiOutput("priors")
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

  output$priors = renderUI({
    map(seq_len(input$add), prior_card)
  })

  d = reactive({
    map(
      seq_len(input$add),
      \(id) {
        a = input[[paste0("a_", id)]]
        b = input[[paste0("b_", id)]]
        req(a, b)

        tibble(
          prior = paste("Prior", id),
          p = seq(0, 1, length.out = 501),
          density = dbeta(p, a + input$x, b + input$n - input$x)
        )
      }
    ) |>
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
