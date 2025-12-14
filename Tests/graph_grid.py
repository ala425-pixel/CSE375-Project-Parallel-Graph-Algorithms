import os
import glob
import numpy as np
import matplotlib.pyplot as plt

# Directory containing the .tsv files
RESULTS_DIR = "Results/Grid"

# Implementation names (excluding Seq_BFS)
impl_names = [
    "Hybrid with VCG",   # BFS_HVGC
    "Sparse with VCG",   # BFS_SVGC
    "Hybrid",            # BFS_H
    "Sparse"             # BFS_S
]

# Column indices
SEQ_COL = 0
IMPL_COLS = [1, 2, 3, 4]

graph_labels = []
avg_speedups = []

# -------------------------------------------------
# Collect and sort files by (rows, cols, f)
# -------------------------------------------------
files = []

for filepath in glob.glob(os.path.join(RESULTS_DIR, "bfs_*.tsv")):
    filename = os.path.basename(filepath)
    _, r, c, f = filename.replace(".tsv", "").split("_")
    files.append((int(r), int(c), float(f[1:]), filepath))

# Sort by increasing rows, then cols, then f
files.sort(key=lambda x: (x[0], x[1], x[2]))

# -------------------------------------------------
# Process files in sorted order
# -------------------------------------------------
for r, c, f, filepath in files:
    data = np.loadtxt(filepath)

    seq_times = data[:, SEQ_COL]
    impl_times = data[:, IMPL_COLS]

    # Compute speedup per run
    speedups = seq_times[:, None] / impl_times

    # Average speedup over the 10 runs
    avg_speedup = speedups.mean(axis=0)

    avg_speedups.append(avg_speedup)

    # Multi-line graph label
    label = f"{r} × {c}\nf = {f}"
    graph_labels.append(label)

avg_speedups = np.array(avg_speedups)

# -----------------------
# Plotting
# -----------------------
num_graphs = len(graph_labels)
num_impls = len(impl_names)

x = np.arange(num_graphs)
width = 0.18

plt.figure(figsize=(14, 6))

for i in range(num_impls):
    plt.bar(
        x + (i - 1.5) * width,
        avg_speedups[:, i],
        width,
        label=impl_names[i]
    )

plt.xticks(x, graph_labels)
plt.ylabel("Average Speedup over Sequential")
plt.xlabel("Graph")
plt.title("Average BFS Speedup per Grid Graph and Implementation")
plt.legend()
plt.grid(axis="y", linestyle="--", alpha=0.5)

plt.tight_layout()
plt.savefig("grid_speedup.png", dpi=300)