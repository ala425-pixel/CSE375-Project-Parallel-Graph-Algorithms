#!/bin/bash

GRAPH_DIR="/proj/cse375-475/bes226/"                          
BFS_EXEC="/proj/cse375-475/bes226/CSE375-Project-Parallel-Graph-Algorithms/PASGAL/src/BFS/bfs"
GROWTH_FACTOR_VALUES=(2 4 6 8 10 12 14)
OUTPUT_DIR="./growth_factor_results"
mkdir -p "$OUTPUT_DIR"

echo "Starting GROWTH_FACTOR benchmarking..."
echo

for graph_file in "$GRAPH_DIR"/*.adj; do
    graph_name=$(basename "$graph_file" .adj)
    output_csv="$OUTPUT_DIR/${graph_name}_growth_factor.csv"

    echo "Graph: $graph_name"
    echo "Writing results to: $output_csv"

    # CSV header
    echo "GROWTH_FACTOR,AverageRuntime" > "$output_csv"

    for th in "${GROWTH_FACTOR_VALUES[@]}"; do
        echo "  Running GROWTH_FACTOR=$th ..."

        export GROWTH_FACTOR=$th

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
