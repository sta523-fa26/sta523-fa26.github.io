library(tidyverse)
library(shiny)
library(bslib)

dist_themes = c(prior = "danger", likelihood = "success", posterior = "primary")

stat_icons = c(
  Mean = "bullseye",
  Median = "symmetry-vertical",
  `95% CI` = "distribute-horizontal"
)

ui = page_sidebar(
  theme = bs_theme(),
  title = "Beta-Binomial Visualizer",
  sidebar = sidebar(
    h4("Data:"),
    sliderInput("x", "# of heads", min=0, max=100, value=7),
    sliderInput("n", "# of flips", min=0, max=100, value=10),
    h4("Prior:"),
    numericInput("a", "Prior # of head", min=0, value=5),
    numericInput("b", "Prior # of tails", min=0, value=5),
    actionButton("run", "Run")
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
        selectInput("summary_dist", "Distribution:", choices = names(dist_themes))
      ),
      class = "d-flex justify-content-between align-items-center"
    ),
    card_body(
      uiOutput("value_boxes", fill = TRUE)
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
      p = seq(0, 1, length.out = 1001)
    ) |>
    mutate(
      prior = dbeta(p, input$a, input$b),
      likelihood = dbinom(input$x, size = input$n, prob = p) |>
      (\(x) {x / (sum(x) / (n() - 1))})(),
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
  }) |>
    bindEvent(input$run)
  
  output$plot = renderPlot({
    dist_colors = bs_get_variables(bs_current_theme(), unname(dist_themes)) |>
      set_names(names(dist_themes))
    
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
    stats = d() |>
      filter(distribution == input$summary_dist) |>
      summarize(
        Mean = (sum(p * density) / sum(density)) |> format(nsmall = 3, digits=3),
        Median = p[(cumsum(density) / sum(density) >= 0.5)][1] |> format(nsmall = 3, digits=3),
        `95% CI` = c(
          p[(cumsum(density) / sum(density) >= 0.025)][1],
          p[(cumsum(density) / sum(density) >= 0.975)][1]
        ) |>
          format(nsmall = 3, digits=3) |>
          paste(collapse = " \u2013 ")
      )

    boxes = imap(
      stats,
      \(value, stat) value_box(
        title = stat,
        value = span(value, class = "text-nowrap"),
        showcase = bsicons::bs_icon(stat_icons[[stat]]),
        theme = dist_themes[[input$summary_dist]]
      )
    ) |>
      unname()

    layout_column_wrap(!!!boxes, width = "250px")
  })
}

thematic::thematic_shiny(font = "auto")
shinyApp(ui = ui, server = server)
