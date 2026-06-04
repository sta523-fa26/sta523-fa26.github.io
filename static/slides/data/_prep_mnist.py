"""
One-time prep: dump sklearn's load_digits dataset to a CSV used by Lec27.

Run from the repo root:
    uv run --with scikit-learn --with pandas --with numpy \\
      python static/slides/data/_prep_mnist.py
"""

from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.datasets import load_digits


def main():
    digits = load_digits()
    X = digits.data.astype(np.int16)
    y = digits.target.astype(np.int16)

    df = pd.DataFrame(X, columns=[f"px{i:02d}" for i in range(X.shape[1])])
    df["label"] = y

    out = Path(__file__).resolve().parent / "mnist_digits.csv"
    df.to_csv(out, index=False)
    print(f"wrote {out} ({df.shape[0]} rows, {df.shape[1]} cols)")


if __name__ == "__main__":
    main()
