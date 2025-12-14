import os
import pandas as pd
import matplotlib.pyplot as plt

RESULT_DIR = "./threads_results"

def main():
    files = [f for f in os.listdir(RESULT_DIR) if f.endswith(".csv")]
    if not files:
        print("No CSV files found in threads_results/")
        return

    plt.figure(figsize=(10, 6))

    for filename in files:
        path = os.path.join(RESULT_DIR, filename)
        graph_name = filename.replace("_threads.csv", "")

        df = pd.read_csv(path)

        # baseline runtime from the FIRST SPARSE_TH entry
        baseline = df["AverageRuntime"].iloc[0]

        # compute speedup = baseline / current_runtime
        df["Speedup"] = baseline / df["AverageRuntime"]

        plt.plot(
            df["THREADS"],
            df["Speedup"],
            marker='o',
            label=graph_name
        )

    plt.xlabel("Number of Threads")
    plt.ylabel("Speedup over single thread")
    plt.title("Scalability")
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.legend(title="Graph")
    plt.tight_layout()

    plt.savefig("threads_speedup.png", dpi=300)
    print("Saved threads_speedup.png")

if __name__ == "__main__":
    main()
