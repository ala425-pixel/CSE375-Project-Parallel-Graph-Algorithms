import os
import glob
import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
from matplotlib.ticker import FuncFormatter

def edge_formatter(x, pos):
    if x >= 1_000_000:
        return f"{x/1_000_000:.1f}".rstrip("0").rstrip(".") + "M"
    elif x >= 1_000:
        return f"{x/1_000:.1f}".rstrip("0").rstrip(".") + "K"
    else:
        return str(int(x))

# Directory containing random graph TSV files
RESULTS_DIR = "Results/Random"

# Implementation names (excluding Seq_BFS)
impl_names = [
    "Hybrid with VCG",   # BFS_HVGC
    "Sparse with VCG",   # BFS_SVGC
    "Hybrid",            # BFS_H
    "Sparse"             # BFS_S
]

SEQ_COL = 0
IMPL_COLS = [1, 2, 3, 4]

# -------------------------------------------------
# Read files and group by n
# -------------------------------------------------
data_by_n = defaultdict(list)

for filepath in glob.glob(os.path.join(RESULTS_DIR, "bfs_*.tsv")):
    filename = os.path.basename(filepath)
    _, n, m = filename.replace(".tsv", "").split("_")

    n = int(n)
    m = int(m)

    data = np.loadtxt(filepath)

    seq_times = data[:, SEQ_COL]
    impl_times = data[:, IMPL_COLS]

    # Speedup per run
    speedups = seq_times[:, None] / impl_times

    # Average over 10 runs
    avg_speedup = speedups.mean(axis=0)

    data_by_n[n].append((m, avg_speedup))

# -------------------------------------------------
# Plotting: one figure per n
# -------------------------------------------------
for n in sorted(data_by_n.keys()):
    entries = sorted(data_by_n[n], key=lambda x: x[0])  # sort by m

    m_values = [e[0] for e in entries]
    speedups = np.array([e[1] for e in entries])

    plt.figure(figsize=(8, 5))

    for i, impl in enumerate(impl_names):
        plt.plot(
            m_values,
            speedups[:, i],
            marker="o",
            label=impl
        )

    plt.xlabel("Number of edges")
    plt.xscale("log")
    plt.xticks(m_values)
    plt.gca().xaxis.set_major_formatter(FuncFormatter(edge_formatter))
    plt.gca().xaxis.get_offset_text().set_visible(False)  
    plt.ylabel("Average Speedup over Sequential")
    plt.title(f"Average BFS Speedup (V = {n:,})")
    plt.legend()
    plt.grid(True, linestyle="--", alpha=0.5)

    plt.tight_layout()
    plt.savefig(f"random_speedup_n{n}.png", dpi=300)