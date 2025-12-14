import os
import pandas as pd
import matplotlib.pyplot as plt

RESULT_DIR = "./growth_factor_results"

def main():
    files = [f for f in os.listdir(RESULT_DIR) if f.endswith(".csv")]
    if not files:
        print("No CSV files found in growth_factor_results/")
        return

    plt.figure(figsize=(10, 6))

    for filename in files:
        path = os.path.join(RESULT_DIR, filename)
        graph_name = filename.replace("_growth_factor.csv", "")

        df = pd.read_csv(path)

        # baseline runtime from the FIRST SPARSE_TH entry
        baseline = df["AverageRuntime"].iloc[0]

        # compute speedup = baseline / current_runtime
        df["Speedup"] = baseline / df["AverageRuntime"]

        plt.plot(
            df["GROWTH_FACTOR"],
            df["Speedup"],
            marker='o',
            label=graph_name
        )

    plt.xlabel("GROWTH_FACTOR value")
    # plt.xscale('log')
    plt.ylabel("Speedup relative to smallest GROWTH_FACTOR value")
    plt.title("Speedup vs GROWTH_FACTOR for Each Graph")
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.legend(title="Graph")
    plt.tight_layout()

    plt.savefig("growth_factor_speedup.png", dpi=300)
    print("Saved growth_factor_speedup.png")

if __name__ == "__main__":
    main()
