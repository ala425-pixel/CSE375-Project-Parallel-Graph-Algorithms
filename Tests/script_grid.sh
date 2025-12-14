#!/bin/bash

GEN=../PASGAL/src/utils/generate_grid_graph
BFS=../PASGAL/src/BFS/bfs_test

# Grid sizes: (rows, cols)
ROWS=(2000 500 125)
COLS=(2000 8000 32000)

# Edge probabilities
FREQS=(0.5 0.75 1)

for i in "${!ROWS[@]}"; do
    r=${ROWS[$i]}
    c=${COLS[$i]}

    for f in "${FREQS[@]}"; do
        echo "Running r=${r}, c=${c}, f=${f}"

        # Generate graph (overwrite graph.adj)
        $GEN -r "$r" -c "$c" -f "$f" -o graph.adj

        # Run BFS benchmark
        $BFS -i graph.adj

        # Rename output
        mv bfs.tsv "Results/Grid/bfs_${r}_${c}_f${f}.tsv"
    done
done

echo "All experiments completed."