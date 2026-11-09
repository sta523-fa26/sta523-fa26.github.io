library(tidyverse)
library(shiny)
library(bslib)

ui = page_sidebar(
  theme = bs_theme(),
  title = "Beta-Binomial Visualizer",
  sidebar = sidebar(
    h4("Data:"),
    sliderInput("x", "# of heads", min=0, max=100, value=7),
    sliderInput("n", "# of flips", min=0, max=100, value=10),
    h4("Prior:"),
    numericInput("a", "Prior # of head", min=0, value=5),
    numericInput("b", "Prior # of tails", min=0, value=5)
  ),
  card(
    card_header("Distributions"),
    card_body(
      plotOutput("plot"),
    ),
    full_screen = TRUE
  ),
  card(
    card_header(
      textOutput("summary_title"),
      popover(
        bsicons::bs_icon("gear"),
        title = "Settings",
        selectInput("summary_dist", "Distribution:", choices = c("prior", "likelihood", "posterior"))
      ),
      class = "d-flex justify-content-between align-items-center"
    ),
    card_body(
      uiOutput("value_boxes")
    )
  )
)


server = function(input, output, session) {
  bs_themer()
  observe({
    updateSliderInput(session, "x", max = input$n)
  }) |>
  bindEvent(input$n)
  
  output$summary_title = renderText({
    paste("Summary Statistics for the", input$summary_dist)
  })
  
  d = reactive({
    tibble(
      p = seq(0, 1, length.out = 1000)
    ) |>
    mutate(
      prior = dbeta(p, input$a, input$b),
      likelihood = dbinom(input$x, size = input$n, prob = p) |>
      (\(x) {x / (sum(x) / n())})(),
      posterior = dbeta(p, input$a + input$x, input$b + input$n - input$x)
    ) |>
    pivot_longer(
      cols = -p,
      names_to = "distribution",
      values_to = "density"
    ) |>
    mutate(
      distribution = forcats::as_factor(distribution)
    )
  })
  
  output$plot = renderPlot({
    current_theme = bs_current_theme()
    
    dist_colors = bs_get_variables(current_theme, c("danger", "success", "primary")) |>
      setNames(c("prior", "likelihood", "posterior"))
    
    ggplot(
      d(),
      aes(x=p, y=density, color=distribution)
    ) +
      geom_line(linewidth=1.5) +
      geom_ribbon(aes(ymax=density, fill=distribution), ymin=0, alpha=0.5) +
      scale_color_manual(values = dist_colors) +
      scale_fill_manual(values = dist_colors)
  })
  
  output$value_boxes = renderUI({

    stat_icons = list(
      Mean = bsicons::bs_icon("bullseye"),
      Median = bsicons::bs_icon("distribute-horizontal"),
      `CI 95%` = bsicons::bs_icon("arrows-expand-vertical")
    )

    dist_themes = list(
      prior = "danger",
      likelihood = "success",
      posterior = "primary"
    )

    stats = d() |>
      filter(distribution == input$summary_dist) |>
      summarize(
        Mean = (sum(p * density) / n()) |> format(nsmall = 3, digits=3),
        Median = p[(cumsum(density/n()) >= 0.5)][1] |> format(nsmall = 3, digits=3),
        `CI 95%`= c(
          p[(cumsum(density/n()) >= 0.025)][1],
          p[(cumsum(density/n()) >= 0.975)][1]
        ) |>
          format(nsmall = 3, digits=3) |>
          paste(collapse = " - ")
      )

    boxes = purrr::imap(
      stats,
      ~ value_box(
        title = .y,
        value = .x,
        showcase = stat_icons[[.y]],
        theme = dist_themes[[input$summary_dist]]
      )
    ) |>
      unname()

    layout_column_wrap(!!!boxes, width = "200px")
  })
}

thematic::thematic_shiny(font = "auto")
shinyApp(ui = ui, server = server)
