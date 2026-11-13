import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
from shiny import App, reactive, render, ui

app_ui = ui.page_sidebar(
    ui.sidebar(
        ui.h4("Data:"),
        ui.input_slider("x", "# of heads", min=0, max=100, value=7),
        ui.input_slider("n", "# of flips", min=0, max=100, value=10),
        ui.h4("Prior:"),
        ui.input_numeric("a", "Prior # of heads", min=0, value=5),
        ui.input_numeric("b", "Prior # of tails", min=0, value=5),
    ),
    ui.output_plot("plot"),
    ui.output_data_frame("table"),
    title="Beta-Binomial Visualizer",
)


def server(input, output, session):
    @reactive.effect
    @reactive.event(input.n)
    def _():
        ui.update_slider("x", max=input.n())

    @reactive.calc
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
            ax.plot(df["p"], df["density"], label=dist)
            ax.fill_between(df["p"], df["density"], alpha=0.3)
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


app = App(app_ui, server)
