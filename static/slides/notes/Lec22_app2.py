import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
from faicons import icon_svg
from shiny import App, reactive, render, ui

dist_themes = {"prior": "danger", "likelihood": "success", "posterior": "primary"}

dist_colors = {"prior": "#dc3545", "likelihood": "#198754", "posterior": "#0d6efd"}

stat_icons = {
    "Mean": "bullseye",
    "Median": "arrows-left-right",
    "95% CI": "arrows-left-right-to-line",
}

app_ui = ui.page_sidebar(
    ui.sidebar(
        ui.accordion(
            ui.accordion_panel(
                "Data",
                ui.input_slider("x", "# of heads", min=0, max=100, value=7),
                ui.input_slider("n", "# of flips", min=0, max=100, value=10),
            ),
            ui.accordion_panel(
                "Prior",
                ui.input_numeric("a", "Prior # of heads", min=0, value=5),
                ui.input_numeric("b", "Prior # of tails", min=0, value=5),
            ),
        ),
        ui.input_action_button("run", "Run"),
    ),
    ui.navset_card_tab(
        ui.nav_panel("Plot", ui.output_plot("plot")),
        ui.nav_panel("Table", ui.output_data_frame("table")),
        title="Distributions",
        full_screen=True,
    ),
    ui.card(
        ui.card_header(
            ui.output_text("summary_title"),
            ui.popover(
                icon_svg("gear"),
                ui.input_select(
                    "summary_dist", "Distribution:", choices=list(dist_themes)
                ),
                title="Settings",
            ),
            class_="d-flex justify-content-between align-items-center",
        ),
        ui.card_body(
            ui.output_ui("value_boxes"),
        ),
    ),
    title="Beta-Binomial Visualizer",
)


def server(input, output, session):
    @reactive.effect
    @reactive.event(input.n)
    def _():
        ui.update_slider("x", max=input.n())

    @render.text
    def summary_title():
        return f"Summary Statistics for the {input.summary_dist()}"

    @reactive.calc
    @reactive.event(input.run)
    def d():
        p = np.linspace(0, 1, 1001)
        lik = stats.binom.pmf(input.x(), input.n(), p)

        return pd.DataFrame({
            "p": p,
            "prior": stats.beta.pdf(p, input.a(), input.b()),
            "likelihood": lik / (lik.sum() / (len(p) - 1)),
            "posterior": stats.beta.pdf(
                p, input.a() + input.x(), input.b() + input.n() - input.x()
            ),
        }).melt(id_vars="p", var_name="distribution", value_name="density")

    @render.plot
    def plot():
        fig, ax = plt.subplots()
        for dist, df in d().groupby("distribution", sort=False):
            ax.plot(df["p"], df["density"], color=dist_colors[dist], label=dist)
            ax.fill_between(
                df["p"], df["density"], color=dist_colors[dist], alpha=0.3
            )
        ax.set(xlabel="p", ylabel="density")
        ax.legend()
        return fig

    @render.data_frame
    def table():
        def summarize(df):
            return pd.Series({
                "mean": (df["p"] * df["density"]).sum() / df["density"].sum(),
                "mode": df["p"][df["density"].idxmax()],
            })

        return (
            d()
            .groupby("distribution", sort=False)
            .apply(summarize)
            .round(3)
            .reset_index()
        )

    @render.ui
    def value_boxes():
        dist = input.summary_dist()
        df = d()[d()["distribution"] == dist]
        cdf = df["density"].cumsum() / df["density"].sum()

        def quantile(prob):
            return df["p"][cdf >= prob].iloc[0]

        summary = {
            "Mean": f"{(df['p'] * df['density']).sum() / df['density'].sum():.3f}",
            "Median": f"{quantile(0.5):.3f}",
            "95% CI": f"{quantile(0.025):.3f} - {quantile(0.975):.3f}",
        }

        boxes = [
            ui.value_box(
                stat,
                value,
                showcase=icon_svg(stat_icons[stat]),
                showcase_layout="top right",
                theme=dist_themes[dist],
            )
            for stat, value in summary.items()
        ]

        return ui.layout_column_wrap(*boxes, width="200px")


app = App(app_ui, server)
