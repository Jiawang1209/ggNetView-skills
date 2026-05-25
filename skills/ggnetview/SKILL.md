---
name: ggnetview
description: Use when writing, debugging, or reviewing R code that uses the ggNetView package to build, analyze, or visualize biological/ecological/microbial association networks (correlation, co-occurrence, WGCNA, SpiecEasi, SparCC) — covers graph construction, deterministic layouts, topology metrics, network comparison, and publication-quality ggraph/ggplot2 figures.
---

# ggNetView

## Overview

ggNetView is an R package (built on ggplot2 / ggraph / tidygraph) for **reproducible, deterministic** network analysis and visualization. The entire package follows **one pipeline**:

```
raw data (matrix / data.frame / adjacency / igraph / WGCNA-TOM)
  → build_graph_from_*()          # returns a tidygraph tbl_graph
  → ggNetView(graph, layout = "…") # returns a ggplot
  → + scale_*_ggnetview() / theme_ggnetview()   # optional ggplot2 layers
  → export_ggnetview(p, filename, …)             # save
```

**Three rules that prevent almost every error** (the baseline failure mode is inventing names — don't):

1. The main plotting function is **`ggNetView()`** — capital N, capital V. Not `ggnetview()`, not `as_netview()`, not `plot()`.
2. The **layout is a STRING** passed to `ggNetView(layout = "stress")`. The `create_layout_*` functions are **internal** — never call them directly.
3. Build the graph object **first** with a `build_graph_from_*()` function; `ggNetView()` only renders an existing graph object.

This is a niche package — if you "remember" a ggNetView function name, you are almost certainly hallucinating. Use the names in this skill.

## When to Use

- Building correlation / co-occurrence / WGCNA / SpiecEasi / SparCC networks in R
- Plotting a network with a reproducible, publication-quality layout
- Computing network topology / node centrality / Zi-Pi
- Identifying keystone taxa (Zi-Pi roles) or hub / influential nodes
- Relating a network or community to environmental factors (Mantel + heatmap)
- Building multi-omics / bipartite / tripartite association networks
- Extracting subgraphs by module or computing per-sample networks
- Comparing networks across groups
- Any time you see `library(ggNetView)` or are asked for "ggNetView" code

## Correctness anchors — guessed-wrong → actually-correct

| If you're about to write… | Use instead |
|---|---|
| `ggnetview(...)` / `as_netview(...)` / `plot(net)` | `build_graph_from_mat(...)` then `ggNetView(graph_obj, ...)` |
| `rmt_threshold(...)` | `ggNetView_RMT(...)$chosen_threshold` |
| `network_metrics()` / `network_summary()` | `get_network_topology(...)$topology` |
| `compare_networks()` / `ggnetview_compare()` | `ggNetView_multi_link(...)$p` |
| `wgcna_network(...)` | `build_graph_from_mat(method = "WGCNA")` or `build_graph_from_wgcna(...)` |
| `create_layout_stress(g)` then plot | `ggNetView(g, layout = "stress")` |
| `net_zipi()` / `plot_zipi()` / `zi_pi()` | `ggnetview_zipi(nodes, adj, "Modularity", "Degree")$plot` (node table + adjacency, NOT a graph) |
| `net_centrality()` / `net_hub()` / `node_metrics()` | `get_node_centrality(g)` / `get_node_ivi(g)` (both return an augmented graph — assign it) |
| `ggNet_mantel()` / `mantel_test()` → a ggplot | `gglink_heatmaps(relation_method = "mantel", mantel_kind = "block_vs_col")` (returns a list of 3) |
| `ggNetCorr()` / `ggNetBuild(bipartite = TRUE)` | `build_graph_from_double_mat(...)` → `ggNetView(layout = "bipartite_gephi_layout")` |
| `subNetwork(modules = ...)` / `netTopology()` | `get_subgraph(g, select_module = ...)` / `get_sample_subgraph_topology(g, mat = ...)` |
| `layout = "bipartite"` / `"tripartite"` | `layout = "bipartite_gephi_layout"` / `"tripartite_gephi_layout"` (+ `layout.module = "order"`) |
| `transform.method = ...` | `transfrom.method = ...` (source spelling — keep the typo) |

## Quick Reference — task → function

| Task | Function(s) |
|---|---|
| Graph from correlation matrix | `build_graph_from_mat()` → `ggNetView()` |
| Graph from adjacency matrix | `build_graph_from_adj_mat()` → `ggNetView()` |
| RMT threshold selection | `ggNetView_RMT()` (returns `$chosen_threshold`) |
| Topology / robustness | `get_network_topology()` (returns list `$topology`, `$Robustness`) |
| Node centrality / IVI / Zi-Pi | `get_node_centrality()`, `get_node_ivi()`, `ggnetview_zipi()` |
| Keystone taxa (Zi-Pi roles) / hub nodes | `ggnetview_zipi(get_graph_nodes(g), get_graph_adjacency(g), ...)`, `get_node_centrality()` |
| Network vs environment (Mantel + heatmap) | `gglink_heatmaps(relation_method = "mantel")`, `mantel_block_vs_col()` |
| Multi-omics / bipartite network | `build_graph_from_double_mat()` / `build_graph_from_multi_mat()` → `ggNetView(layout = "bipartite_gephi_layout")` |
| Subgraph by module / per sample | `get_subgraph()`, `get_sample_subgraph()`, `get_sample_subgraph_topology()` |
| Specific layout | `ggNetView(graph, layout = "<name>")` |
| Compare networks across groups | `ggNetView_multi_link()` |
| WGCNA (quick / full) | `build_graph_from_mat(method="WGCNA")` / `trans_TOM_in_WGCNA()` → `build_graph_from_wgcna()` |
| Scales / theme | `scale_fill_ggnetview()`, `scale_color_ggnetview()`, `theme_ggnetview()` |
| Save figure | `export_ggnetview()` |

Full signatures and the complete exported-function list: **api-reference.md**.

## The canonical pipeline (one complete example)

```r
library(tidyverse)
library(ggNetView)
data("otu_rare_relative")   # variables in ROWS, samples in COLUMNS
data("tax_tab")             # node annotation; first column = node ID

graph_obj <- build_graph_from_mat(
  mat              = otu_rare_relative,
  transfrom.method = "none",      # NOTE the source spelling "transfrom"
  r.threshold      = 0.7,
  p.threshold      = 0.05,
  method           = "WGCNA",     # case-sensitive: WGCNA/SpiecEasi/SPARCC/cor/Hmisc
  cor.method       = "pearson",
  proc             = "bonferroni",
  module.method    = "Fast_greedy",
  node_annotation  = tax_tab,
  top_modules      = 15,
  seed             = 1115         # determinism knob, used throughout the package
)

p <- ggNetView(
  graph_obj     = graph_obj,
  layout        = "stress",       # string; reproducible publication layout
  layout.module = "adjacent",
  group.by      = "Modularity",   # capital-M column added by the builder
  fill.by       = "Modularity",
  seed          = 1115
)

p + theme_ggnetview()
export_ggnetview(p, filename = "network.pdf", width = 8, height = 8)
```

End-to-end examples for all 10 tasks (6 core + 4 advanced: Zi-Pi/hub, Mantel
environment, multi-omics/bipartite, subgraph/per-sample): **workflows.md**.

## Common Mistakes

- **Inventing function names.** The #1 failure. ggNetView's API does not follow ggraph/igraph naming. Check api-reference.md.
- **Calling `create_layout_*` directly.** They are internal; pass the suffix as `layout = "..."` to `ggNetView()`.
- **`transform.method`.** The real argument is `transfrom.method` (typo preserved in source). Same for output columns: `Cohension_*` (not "Cohesion"), `Random_nerwork`.
- **Wrong matrix orientation.** `build_graph_from_mat` / `ggNetView_RMT` / `get_network_topology` want **variables in rows, samples in columns**. Native WGCNA functions (`adjacency`, `pickSoftThreshold`) want the opposite (samples in rows).
- **Treating topology output as a data.frame.** It's a list — use `$topology`. With `mat = NULL`, cohesion/robustness/stability come back `NA`.
- **RMT building the graph.** It doesn't — feed `out$chosen_threshold` into `build_graph_from_mat(r.threshold = ...)`, keeping `method`/`cor.method`/`transfrom.method` identical to the RMT scan.
- **Forgetting `seed`.** Default is `1115`. Omitting/changing it breaks reproducibility.
- **`ggnetview_zipi()` is not a graph plotter.** Feed it `get_graph_nodes(g)` +
  `get_graph_adjacency(g)`, with the `modularity_col`/`degree_col` names — not the graph.
- **Centrality results vanishing.** `get_node_centrality()` / `get_node_ivi()` *return* an
  augmented `tbl_graph`; assign it (`g <- get_node_centrality(g)`), don't call for side effects.
- **`gglink_heatmaps()` returns a list of 3**, not a ggplot — use `out[[1]]` (straight) /
  `out[[2]]` (curved) / `out[[3]]` (stats). `env`/`spec` rows must align; `length(env_select)`
  must equal `length(orientation)`. Use `mantel_kind = "block_vs_col"` for the ecological Mantel.
- **Bipartite/tripartite layout splits on `Modularity` and needs exactly 2/3 levels.**
  `build_graph_from_double_mat()` sets `Modularity` from community detection — for a clean
  omics-vs-omics split use `build_graph_from_double_mat_with_module()` with a 2-level
  `Modularity`, and the layout string keeps the `_layout` suffix + `layout.module = "order"`.
- **`get_subgraph()` / `get_sample_subgraph()` return lists** — the graph is in
  `$sub_graph_select`; per-sample subgraphs in `$sub_graph_all`.

Error messages and fixes: **troubleshooting.md**.
