# Lecture 23 R Shiny apps

## Lec23_app1.R
This app compares beta prior, likelihood, and posterior curves for one or more priors given the same binomial data. The user controls the number of heads and flips, and can add additional prior cards, each with its own Beta(a, b) parameters. The plot facets by prior, so every prior is shown in its own panel.

Compared with the later versions, this is the baseline app: it supports adding priors, but not removing them.

## Lec23_app2.R
This version does the same beta-binomial comparison, but it adds the ability to remove a prior after it has been added. Each prior card gets its own delete button, and the server keeps track of the active prior IDs so removed priors stop contributing to the plot.

Compared with Lec23_app1.R, the main change is dynamic deletion of individual priors.

## Lec23_app3.R
This version refactors each prior into a Shiny module. The prior inputs and their remove behavior are encapsulated in `prior_ui()` and `prior_server()`, which makes the code more modular and easier to extend.

Compared with Lec23_app2.R, the functionality is essentially the same, but the implementation is cleaner and uses namespacing/module structure instead of manually managing IDs and observers.
