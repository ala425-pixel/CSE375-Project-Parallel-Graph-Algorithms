#pragma once
#include <climits>
#include <cstdlib>

#include "graph.h"
#include "hashbag.h"
#include "parlay/sequence.h"
#include "parlay/slice.h"
#include "utils.h"

using namespace std;
using namespace parlay;

template <class Graph>
class BFS_S{
  using NodeId = typename Graph::NodeId;
  using EdgeId = typename Graph::EdgeId;

  static constexpr NodeId DIST_MAX = numeric_limits<NodeId>::max();
  static constexpr size_t LOCAL_QUEUE_SIZE = 128; // Used for Vetrical Control Granularity (VCG) optimization
						  // Tells us how many nodes a thread should explore before adding to global frontier
						  // Only in spare relax
  static constexpr size_t BLOCK_SIZE = 1024;
  static constexpr size_t NUM_SAMPLES = 1024; // Used to estimate number of nodes in a frontier
  // static constexpr size_t SPARSE_TH = 20; // Threshold for determining sparse relax or dense relax. Depends on the frontier size.
  static constexpr size_t GROWTH_FACTOR = 10; // Threshold for determining if VGC should be used

  const Graph &G;
  const int LOG2N;
  const size_t num_bags;
  size_t round;
  sequence<hashbag<NodeId>> bags;
  sequence<NodeId> frontier;
  sequence<NodeId> dist;
  sequence<int> bag_id;
  sequence<atomic<bool>> in_frontier;

 public:
  BFS_S() = delete;
  BFS_S(const Graph &_G)
      : G(_G), LOG2N(log2_up(G.n)), num_bags(log2_up(LOCAL_QUEUE_SIZE) + 2) {
    bags = sequence<hashbag<NodeId>>(num_bags, hashbag<NodeId>(G.n));
    frontier = sequence<NodeId>::uninitialized(G.n);
    dist = sequence<NodeId>::uninitialized(G.n);
    bag_id = sequence<int>::uninitialized(G.n);
    in_frontier = sequence<atomic<bool>>(G.n);
  }

  void add_to_frontier(NodeId v) {
    int id = dist[v] == 0 ? 0 : log2_up(dist[v]);
    if (in_frontier[v] == false) {
      in_frontier[v] = true;
      write_min(&bag_id[v], id);
      bags[id % num_bags].insert(v);
    } else {
      if (write_min(&bag_id[v], id)) {
        bags[id % num_bags].insert(v);
      }
    }
  }

// estimate the number of nodes in the frontier. More accurate as NUM_SAMPLES gets larger
  size_t estimate_size([[maybe_unused]] size_t id) {
    static uint32_t seed = 951;
    size_t hits = 0;
    for (size_t i = 0; i < NUM_SAMPLES; i++) {
      NodeId u = hash32(seed) % G.n;
      if (dist[u] == round) {
        hits++;
      }
      seed++;
    }
    return hits * G.n / NUM_SAMPLES;
  }

  void visit_neighbors_parallel(NodeId u) { 
    parallel_for(
        G.offsets[u], G.offsets[u + 1],
        [&](size_t i) {
          NodeId v = G.edges[i].v;
          if (write_min(&dist[v], dist[u] + 1)) {
            add_to_frontier(v);
          }
        },
        BLOCK_SIZE);
    }

  void visit_neighbors_sequential(NodeId u, NodeId *local_queue, size_t &rear) {
    for (EdgeId i = G.offsets[u]; i < G.offsets[u + 1]; i++) {
      NodeId v = G.edges[i].v;
      if (write_min(&dist[v], dist[u] + 1)) {
        if (rear < LOCAL_QUEUE_SIZE) {
          local_queue[rear++] = v;
        } else {
          add_to_frontier(v);
        }
      }
    }
  }

  void sparse_relax(size_t id, size_t frontier_size) {
    parallel_for(0, frontier_size, [&](size_t i) {
      NodeId f = frontier[i];
      in_frontier[f] = false;
      if (id == 0 || id == log2_up(dist[f])) {
        visit_neighbors_parallel(f);
      }
    });
  }

  sequence<NodeId> bfs(NodeId s) {
    std::thread::hardware_concurrency();
    parallel_for(0, G.n, [&](size_t i) {
      in_frontier[i] = false;
      dist[i] = DIST_MAX;
      bag_id[i] = LOG2N;
    });

    dist[s] = 0;
    add_to_frontier(s);

    round = 0;
    // size_t prev_size = 0;
    // int count = 0;
    for (int i = 0; i <= LOG2N; i++) {
      if (i != 0) {
        round = max(round, (size_t)((1 << (i - 1)) + 1));
      }
      while (true) {
	// count++;
        // internal::timer t;
        // printf("prev_size: %zu, approx_size: %zu\n", prev_size, approx_size);

        size_t frontier_size =
            bags[i % num_bags].pack_into(make_slice(frontier));
        // prev_size = frontier_size;
        if (!frontier_size) {
          break;
        }
        // printf("Round %zu: size: %zu, local: %d, ", round, frontier_size,
        // use_local_queue);
        sparse_relax(i, frontier_size);
        round++;
        // t.next("sparse");
      }
    }

    for (size_t i = 0; i < num_bags; i++) {
      assert(bags[i].pack_into(make_slice(frontier)) == 0);
    }
    // printf("diameter = %d\n", count);
    return dist;
  }
};

