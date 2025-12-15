#include "sssp.h"

#include <queue>
#include <type_traits>


#include "dijkstra.h"
#include "graph.h"

typedef uint32_t NodeId;
typedef uint64_t EdgeId;
#ifdef FLOAT
typedef float EdgeTy;
#else
typedef uint32_t EdgeTy;
#endif
constexpr int NUM_SRC = 1;
constexpr int NUM_ROUND = 5;
//constexpr int LOG2_WEIGHT = 18;

template <class Algo, class Graph, class NodeId = typename Graph::NodeId>
void run(Algo &algo, [[maybe_unused]] const Graph &G, NodeId s, bool verify, bool dump, uint32_t threshold) {
  //printf("Starting run\n");
  double total_time = 0;
  double avg_edge_visits_total = 0.0;
  pair<sequence<EdgeTy>, double> res;
  sequence<EdgeTy> dist;
  for (int i = 0; i <= NUM_ROUND; i++) {
    internal::timer t;
    res = algo.sssp(s, threshold);
    dist = res.first;
    t.stop();
    if (i == 0) {
      //printf("Warmup Round: %f\n", t.total_time());
    } else {
      //printf("Round %d: %f\n", i, t.total_time());
      total_time += t.total_time();
      avg_edge_visits_total += res.second;
    }
  }
  // return avg. edge visits and avg. exec. time
  double average_time = total_time / NUM_ROUND;
  double average_edge_visits = avg_edge_visits_total / NUM_ROUND;
  printf("Average time: %f\n", average_time);
  printf("Average edge visits: %f\n", average_edge_visits);

  ofstream ofs("sssp.tsv", ios_base::app);
  ofs << s << '\t' << average_time << '\n';
  ofs.close();

  if (verify) {
    printf("Running verifier...\n");
    Dijkstra verifier(G);
    auto exp_dist = verifier.dijkstra(s);
    assert(dist == exp_dist);
    printf("Passed!\n");
  }
  if (dump) {
    ofstream ofs("sssp.out");
    for (size_t i = 0; i < dist.size(); i++) {
      ofs << dist[i] << '\n';
    }
    ofs.close();
  }
  printf("\n");
}

template <class Algo, class Graph>
void run(Algo &algo, const Graph &G, bool verify, bool dump, uint32_t threshold) {
  for (int v = 0; v < NUM_SRC; v++) {
    uint32_t s = hash32(v) % G.n;
    printf("source %d: %-10d\n", v, s);
    run(algo, G, s, verify, dump, threshold);
  }
}

int main(int argc, char *argv[]) {
  if (argc == 1) {
    fprintf(stderr,
            "Usage: %s [-i input_file] [-a algorithm] [-p parameter] [-r source] [-m threshold]"
	    "[-t distribution] [-l lower bound] [-u upper bound] [-s] [-v] [-d]\n"
            "Options:\n"
            "\t-i,\tinput file path\n"
            "\t-a,\talgorithm: [rho-stepping] [delta-stepping] [bellman-ford]\n"
            "\t-p,\tparameter(e.g. delta, rho)\n"
            "\t-s,\tsymmetrized input graph\n"
            "\t-v,\tverify result\n"
            "\t-d,\tdump distances to file\n"
	    "\t-r,\tsource vertex\n"
	    "\t-m,\tsparse/dense threshold parameter\n"
	    "\t-t,\trandom edge weight distribution\n"
	    "\t-l,\tlower bound edge weight\n"
	    "\t-u,\tupper bound edge weight\n",
            argv[0]);
    return 0;
  }
  char c;
  char const *input_path = nullptr;
  int algorithm = rho_stepping;
  string parameter;
  uint32_t source = UINT_MAX;
  bool symmetrized = false;
  bool verify = false;
  bool dump = false;
  uint32_t threshold = 20;
  string distribution;
  uint32_t lower = 1;
  uint32_t upper = 10;
  while ((c = getopt(argc, argv, "i:a:p:r:m:t:l:u:svd")) != -1) {
    switch (c) {
      case 'i':
        input_path = optarg;
        break;
      case 'a':
        if (!strcmp(optarg, "rho-stepping")) {
          algorithm = rho_stepping;
        } else if (!strcmp(optarg, "delta-stepping")) {
          algorithm = delta_stepping;
        } else if (!strcmp(optarg, "bellman-ford")) {
          algorithm = bellman_ford;
        } else {
          std::cerr << "Error: Unknown algorithm " << optarg << std::endl;
          abort();
        }
        break;
      case 'p':
        parameter = string(optarg);
        break;
      case 'r':
        source = atol(optarg);
        break;
      case 's':
        symmetrized = true;
        break;
      case 'v':
        verify = true;
        break;
      case 'd':
        dump = true;
        break;
      case 'm':
	threshold = atol(optarg);
	printf("threshold\n");
	break;
      case 't':
	distribution = string(optarg);
	break;
      case 'l':
	lower = atol(optarg);
	break;
      case 'u':
	upper = atol(optarg);
	break;
      default:
        std::cerr << "Error: Unknown option " << optopt << std::endl;
        abort();
    }
  }

  printf("Reading graph...\n");
  Graph<NodeId, EdgeId, EdgeTy> G;
  G.symmetrized = symmetrized;
  if (!strcmp(input_path, "random")) {
    G.generate_random_graph();
  } else {
    G.read_graph(input_path);
  }
  if (!G.weighted) {
    printf("Generating edge weights...\n");
    G.generate_random_weight(distribution, lower, upper);
  }

  fprintf(stdout, "Running on %s: |V|=%zu, |E|=%zu, num_src=%d, num_round=%d\n",
          input_path, G.n, G.m, NUM_SRC, NUM_ROUND);

  if (algorithm == rho_stepping) {
    size_t rho = 1 << 20;
    if (!parameter.empty()) {
      Rho_Stepping solver(G);
      rho = stoull(parameter);
    }
    Rho_Stepping solver(G, rho);
    if (source == UINT_MAX) {
      run(solver, G, verify, dump, threshold);
    } else {
      run(solver, G, source, verify, dump, threshold);
    }
  } else if (algorithm == delta_stepping) {
    EdgeTy delta = 1 << 15;
    if (!parameter.empty()) {
      if constexpr (is_integral_v<EdgeTy>) {
        delta = stoull(parameter);
      } else {
        delta = stod(parameter);
      }
    }
    Delta_Stepping solver(G, delta);
    if (source == UINT_MAX) {
      run(solver, G, verify, dump, threshold);
    } else {
      run(solver, G, source, verify, dump, threshold);
    }
  } else if (algorithm == bellman_ford) {
    Bellman_Ford solver(G);
    if (source == UINT_MAX) {
      run(solver, G, verify, dump, threshold);
    } else {
      run(solver, G, source, verify, dump, threshold);
    }
  }
  return 0;
}
