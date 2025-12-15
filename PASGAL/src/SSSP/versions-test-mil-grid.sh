make
echo "testing mil grid\n"

echo "bellman ford\n"
./sssp -i ../../graph_inputs/mil_grid.adj -a bellman-ford -t uniform -l 1 -u 10

echo "delta stepping\n"
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 1 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 2 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 4 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 6 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 8 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 16 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 32 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 64 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 128 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 256 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a delta-stepping -p 512 -t uniform -l 1 -u 10

echo "rho stepping\n"
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 1 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 2 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 4 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 8 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 16 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 32 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 64 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 128 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 256 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 512 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 1024 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 2048 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 4096 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 8192 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 16384 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 32768 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 65000 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 130000 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 250000 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 500000 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 1000000 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 2000000 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 4000000 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 8000000 -t uniform -l 1 -u 10
./sssp -i ../../graph_inputs/mil_grid.adj -a rho-stepping -p 1600000 -t uniform -l 1 -u 10
