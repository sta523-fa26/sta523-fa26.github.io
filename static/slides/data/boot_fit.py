import numpy as np
from statsmodels.nonparametric.smoothers_lowess import lowess

def boot_fit(seed, d, grid, span = 0.3):
    rng = np.random.default_rng(seed)
    b = d.sample(frac = 1, replace = True, random_state = rng)
    fitted = lowess(b["y"], b["x"], frac = span, it = 0, return_sorted = False)
    pred = lowess(b["y"], b["x"], frac = span, it = 0, xvals = grid)
    return pred + rng.choice(b["y"].to_numpy() - fitted, len(grid))
