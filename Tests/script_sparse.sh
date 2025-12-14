#!/bin/bash

GRAPH_DIR="/proj/cse375-475/bes226/"                          
BFS_EXEC="/proj/cse375-475/bes226/CSE375-Project-Parallel-Graph-Algorithms/PASGAL/src/BFS/bfs"
SPARSE_TH_VALUES=(5 10 20 40 60 80 100)
OUTPUT_DIR="./sparse_th_results"
mkdir -p "$OUTPUT_DIR"

echo "Starting SPARSE_TH benchmarking..."
echo

for graph_file in "$GRAPH_DIR"/*.adj; do
    graph_name=$(basename "$graph_file" .adj)
    output_csv="$OUTPUT_DIR/${graph_name}_sparse_th.csv"

    echo "Graph: $graph_name"
    echo "Writing results to: $output_csv"

    # CSV header
    echo "SPARSE_TH,AverageRuntime" > "$output_csv"

    for th in "${SPARSE_TH_VALUES[@]}"; do
        echo "  Running SPARSE_TH=$th ..."

        export SPARSE_TH=$th

        # Run BFS once per sparse threshold
        output="$($BFS_EXEC -i "$graph_file" 2>/dev/null)"

        # Extract all “Average time:” values
        averages=$(echo "$output" | grep "Average time:" | awk '{print $3}')

        # Compute mean
        total=0
        count=0
        for t in $averages; do
            total=$(echo "$total + $t" | bc -l)
            count=$((count + 1))
        done

        if [[ $count -eq 0 ]]; then
            echo "ERROR: No average times found"
            mean="NaN"
        else
            mean=$(echo "scale=6; $total / $count" | bc -l)
        fi

        echo "    Mean runtime = $mean"

        # Write to CSV
        echo "$th,$mean" >> "$output_csv"
    done

    echo
done

echo "Done! Results are in $OUTPUT_DIR/"
