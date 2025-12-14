#!/bin/bash

GRAPH_DIR="/proj/cse375-475/bes226/"                          
BFS_EXEC="/proj/cse375-475/bes226/CSE375-Project-Parallel-Graph-Algorithms/PASGAL/src/BFS/bfs_test"

echo "Starting test..."
echo

for graph_file in "$GRAPH_DIR"/*.adj; do
    graph_name=$(basename "$graph_file" .adj)

    echo "Graph: $graph_name"
    echo "$graph_name" >> bfs.tsv
    $BFS_EXEC -i "$graph_file" 2>/dev/null

    echo
done

echo "Done!"
