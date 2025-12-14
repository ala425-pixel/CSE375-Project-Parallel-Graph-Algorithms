import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict

INPUT_FILE = "output.tsv"

NUM_IMPLEMENTATIONS = 4
TRIALS_PER_GRAPH = 10

# Graph names (expected order)
GRAPHS = ["amazon", "email", "facebook", "journal", "pokec", "roads"]

def parse_file(filename):
    """
    Returns:
        data[impl][graph] = list of speedups
    """
    data = defaultdict(lambda: defaultdict(list))

    with open(filename, "r") as f:
        lines = [line.strip() for line in f if line.strip()]

    impl = -1
    i = 0

    while i < len(lines):
        line = lines[i]

        # New implementation starts when we see the first graph again
        if line == GRAPHS[0]:
            impl += 1

        graph = line
        i += 1

        for _ in range(TRIALS_PER_GRAPH):
            first, second, _ = lines[i].split()
            speedup = float(second) / float(first)
            data[impl][graph].append(speedup)
            i += 1

    return data


def compute_averages(data):
    """
    Returns:
        avg[impl][graph] = average speedup
    """
    avg = defaultdict(dict)
    for impl, graphs in data.items():
        for graph, values in graphs.items():
            avg[impl][graph] = np.mean(values)
    return avg


def plot_bar_chart(avg):
    implementations = sorted(avg.keys())
    num_graphs = len(GRAPHS)

    bar_width = 0.18
    x = np.arange(num_graphs)

    plt.figure(figsize=(12, 5))

    impl_names = ['Hybrid with VCG', 'Sparse with VCG', 'Hybrid', 'Sparse']
    
    for idx, impl in enumerate(implementations):
        values = [avg[impl][g] for g in GRAPHS]
        plt.bar(
            x + idx * bar_width,
            values,
            width=bar_width,
            label=f"{impl_names[impl]}"
        )

    plt.xticks(x + bar_width * 1.5, GRAPHS)
    plt.ylabel("Average Speedup over Sequential")
    plt.xlabel("Graph")
    plt.title("Average Speedup per Graph and Implementation")
    plt.legend()
    plt.tight_layout()
    plt.savefig("speedup.png", dpi=300)


if __name__ == "__main__":
    data = parse_file(INPUT_FILE)
    avg = compute_averages(data)
    plot_bar_chart(avg)
