#!/bin/bash

GEN=../PASGAL/src/utils/generate_random_graph
BFS=../PASGAL/src/BFS/bfs_test

# num vertices
V=(100000 500000 1000000)

# Edges/Vertices ratio
MULT=(2 4 8 16 32)

for i in "${!V[@]}"; do
    v=${V[$i]}

    for m in "${MULT[@]}"; do
        edges=$(($v * $m))
        echo "Running n=${V}, m=${edges}"

        # Generate graph (overwrite graph.adj)
        $GEN -n "$v" -m "$edges" -o graph.adj

        # Run BFS benchmark
        $BFS -i graph.adj

        # Rename output
        mv bfs.tsv "Results/Random/bfs_${v}_${edges}.tsv"
    done
done

echo "All experiments completed."