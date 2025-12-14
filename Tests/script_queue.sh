#!/bin/bash

GRAPH_DIR="/proj/cse375-475/bes226/"                          
BFS_EXEC="/proj/cse375-475/bes226/CSE375-Project-Parallel-Graph-Algorithms/PASGAL/src/BFS/bfs"
LOCAL_QUEUE_SIZE_VALUES=(16 32 64 128 256 512 1024)
OUTPUT_DIR="./local_queue_size_results"
mkdir -p "$OUTPUT_DIR"

echo "Starting LOCAL_QUEUE_SIZE benchmarking..."
echo

for graph_file in "$GRAPH_DIR"/*.adj; do
    graph_name=$(basename "$graph_file" .adj)
    output_csv="$OUTPUT_DIR/${graph_name}_local_queue_size.csv"

    echo "Graph: $graph_name"
    echo "Writing results to: $output_csv"

    # CSV header
    echo "LOCAL_QUEUE_SIZE,AverageRuntime" > "$output_csv"

    for th in "${LOCAL_QUEUE_SIZE_VALUES[@]}"; do
        echo "  Running LOCAL_QUEUE_SIZE=$th ..."

        export LOCAL_QUEUE_SIZE=$th

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
