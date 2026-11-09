library(tidyverse)
library(shiny)
library(bslib)

palette = c("seagreen", "mediumpurple", "goldenrod", "steelblue", "rosybrown", "cadetblue")

ui = page_sidebar(
  title = "Beta-Binomial Visualizer",
  sidebar = sidebar(
    h4("Data:"),
    sliderInput("x", "# of heads", min=0, max=100, value=7),
    sliderInput("n", "# of flips", min=0, max=100, value=10),
    h4("Prior:"),
    numericInput("alpha", "Prior # of head", min=0, value=5),
    numericInput("beta", "Prior # of tails", min=0, value=5),
    checkboxInput("options", "Show Options", value = FALSE),
    conditionalPanel(
      "input.options == true",
      checkboxInput("bw", "Use theme_bw", value = FALSE),
      checkboxInput("facet", "Use facets", value = FALSE),
      
      selectInput("prior", "Color for prior", choices = palette, selected = "seagreen"),
      selectInput("likelihood", "Color for likelihood", choices = palette, selected = "mediumpurple"),
      selectInput("posterior", "Color for posterior", choices = palette, selected = "goldenrod")
    )
  ),
  plotOutput("plot"),
  tableOutput("table") 
)

server = function(input, output, session) {

  selected_colors = reactive({
    req(input$prior, input$likelihood, input$posterior)
    c(
      prior = input$prior,
      likelihood = input$likelihood,
      posterior = input$posterior
    )
  })

  # Each dropdown excludes colors selected for the other distributions.
  observe({
    colors = selected_colors()
    for (dist in names(colors)) {
      other_colors = colors[names(colors) != dist]
      updateSelectInput(
        session, dist,
        choices = palette[!palette %in% other_colors],
        selected = colors[[dist]]
      )
    }
  })

  observe({
    updateSliderInput(session, "x", max = input$n)
  }) |>
    bindEvent(input$n)
  
  d = reactive({
    req(input$alpha > 0, input$beta > 0, input$x <= input$n)

    tibble(
      p = seq(0, 1, length.out = 1000)
    ) |>
    mutate(
      prior = dbeta(p, input$alpha, input$beta),
      likelihood = dbinom(input$x, size = input$n, prob = p) /
        (choose(input$n, input$x) * beta(input$x + 1, input$n - input$x + 1)),
      posterior = dbeta(p, input$alpha + input$x, input$beta + input$n - input$x)
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
    g = ggplot(d(), aes(x=p, y=density, color=distribution)) +
    geom_line(linewidth=1.5) +
    geom_ribbon(aes(ymax=density, fill=distribution), ymin=0, alpha=0.5) +
    scale_color_manual(values = selected_colors()) +
    scale_fill_manual(values = selected_colors())
    
    if (input$bw)
    g = g + theme_bw()
    
    if (input$facet) 
    g = g + facet_wrap(~distribution)
    
    g
  })
  
  output$table = renderTable({
    d() |>
    group_by(distribution) |>
    summarize(
      mean = sum(p * density) / n(),
      median = p[(cumsum(density/n()) >= 0.5)][1],
      q025 = p[(cumsum(density/n()) >= 0.025)][1],
      q975 = p[(cumsum(density/n()) >= 0.975)][1]
    )
  })
}

shinyApp(ui = ui, server = server)
