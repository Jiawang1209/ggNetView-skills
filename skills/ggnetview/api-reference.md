# ggNetView API Reference

Package version 0.1.0. All `build_graph_from_*` return a `tidygraph::tbl_graph`.
`ggNetView()` and the `gg*` plotters return a `ggplot` (or a list when a `return_*`
flag is set). This file is the authoritative name/signature list — when in doubt,
copy names from here rather than guessing.

## Exported functions, grouped by purpose

**Graph builders (`build_graph_from_*`) → all return `tbl_graph`:**
`build_graph_from_mat`, `build_graph_from_df`, `build_graph_from_module`,
`build_graph_from_adj_mat`, `build_graph_from_adj_mat_module`,
`build_graph_from_double_mat`, `build_graph_from_double_mat_with_module`,
`build_graph_from_igraph`, `build_graph_from_wgcna`, `build_graph_from_consensus`,
`build_graph_from_multi_mat`, `build_graph_from_pie`, `build_graph_from_enrichGO`,
`build_graph_from_stringdb`, `build_graph_from_node_edge`

**Plotting (`ggNetView*` / `gg*`):**
`ggNetView` (main entry point), `ggNetView_RMT` (RMT threshold scan),
`ggNetView_multi`, `ggNetView_multi_link` (multi-network comparison),
`ggnetview_zipi` (Zi-Pi keystone plot), `ggnetview_modularity_heatmaps`,
`gglink_heatmaps`, `gglink_heatmaps_2`, `gglink_heatmap_triple`

**Getters / extractors (`get_*`):**
`get_graph_nodes`, `get_graph_adjacency`, `get_info_from_graph`, `get_subgraph`,
`get_sample_subgraph`, `get_node_centrality`, `get_node_ivi`, `get_palette`,
`get_network_topology`, `get_network_topology_parallel`,
`get_sample_subgraph_topology`, `get_sample_subgraph_topology_parallel`

**Scales / theme:** `scale_fill_ggnetview`, `scale_color_ggnetview`, `theme_ggnetview`

**Export:** `export_ggnetview`

**Mantel tests:** `mantel_pairwise`, `mantel_between_blocks`, `mantel_block_vs_col`

**Transform / manipulation:** `trans_TOM_in_WGCNA`, `trans_adjacency_matrix_to_df`,
`order_graph`, `update_graph_modules`, `update_graph_modules2`, `deg`

**Rcpp correlation engines:** `sparcc_matrix_rcpp`, `sparcc_pvalue_rcpp`,
`spieceasi_matrix_rcpp`

**Pipe:** `%>%`

**NOT exported (internal — never call directly):** all `create_layout_*` functions
(~64 of them). Pass their suffix as the `layout` string to `ggNetView()`.

## Key signatures

### build_graph_from_mat
Build a correlation/co-occurrence graph from a raw feature×sample matrix.
```r
build_graph_from_mat(
  mat,                                   # variables in ROWS, samples in COLUMNS
  transfrom.method = c("none","scale","center","log2","log10","ln",
                       "rrarefy","rrarefy_relative"),
  r.threshold = 0.7,
  p.threshold = 0.05,
  method      = c("WGCNA","SpiecEasi","SPARCC","cor","Hmisc"),   # case-sensitive
  cor.method  = c("pearson","kendall","spearman"),
  proc        = c("holm","hochberg","hommel","bonferroni","BH","BY","fdr","none"),
  module.method = c("Fast_greedy","Walktrap","Edge_betweenness","Spinglass"),
  SpiecEasi.method = c("mb","glasso"),
  sparcc_R = 20,
  node_annotation = NULL,                # data.frame, first column = node ID
  top_modules = 15,
  seed = 1115
)
```
Nodes gain columns: `modularity, modularity2, modularity3, Modularity, Degree,
Strength` (+ annotation). `Modularity` (capital M) is the grouping/fill column.

### build_graph_from_adj_mat
```r
build_graph_from_adj_mat(
  adjacency_matrix,
  module.method = c("Fast_greedy","Walktrap","Edge_betweenness","Spinglass"),
  node_annotation = NULL,
  top_modules = 15,
  seed = 1115
)
```

### ggNetView (main plotting entry point)
```r
ggNetView(
  graph_obj,
  layout        = "<name>",   # STRING → internally create_layout_<name>()
  layout.module = c("random","adjacent","order"),
  group.by      = "Modularity",
  fill.by       = "Modularity",
  center        = FALSE,
  shrink        = 0.9,
  linealpha     = 0.2,
  seed          = 1115,
  return_layout = FALSE,      # TRUE → returns list($plot, $layout_data)
  ...                         # pointsize, inner_shrink (WGCNA layout), etc.
)
```
Returns a `ggplot` (so you can add `+ scale_*` / `+ theme_*`). `inner_shrink` is
only honored by `layout = "WGCNA"`. `layout.module = "order"` is required by the
multipartite / circular_modules layouts.

**Valid `layout` strings:**
- Force/algorithmic: `fr`, `fr1`, `fr2`, `kk`, `stress`, `lgl`, `nicely`, `nicely1`, `gephi`, `randomly`
- Geometric frames: `circle`, `circle_outline`, `grid`, `square`, `square2`, `square_outline`, `rectangle`, `rectangle_outline`, `diamond`, `diamond_outline`, `star`, `star_concentric`, `petal`, `petal2`, `heart_centered`, `multirings`, `rightiso_layers`, `dendrogram`
- Module-aware: `WGCNA`, `circular_modules_gephi_layout`, `circular_modules_equal_gephi_layout`, `consensus_module_gephi`, `consensus_module_equal_gephi`, and the `circular_modules_[equal_]{diamond,grid,heart_centered,petal,petal2,square,square2,star,star_concentric}_layout` family
- Multipartite (subgraphs): `bipartite_layout`, `bipartite_gephi_layout`, `tripartite_layout`, `tripartite_gephi_layout`, `tripartite_equal_gephi_layout`, `quadripartite_layout`, `quadripartite_gephi_layout`, `quadripartite_equal_gephi_layout`, `cross_quadripartite_gephi_layout`, `cross_quadripartite_equal_gephi_layout`, `pentapartite_layout`, `pentapartite_gephi_layout`, `pentapartite_equal_gephi_layout`

**Suffix rule:** bare names (`fr`, `gephi`, `kk`, `stress`, `diamond`, `petal`) for
the simple layouts, but module/multipartite layouts need the literal `_layout`
suffix (`circular_modules_petal_layout`, `bipartite_gephi_layout`). `"petal"` and
`"circular_modules_petal_layout"` are different layouts.

### ggNetView_RMT
Random-matrix-theory scan to pick a correlation threshold. Does NOT build a graph.
```r
ggNetView_RMT(
  mat,
  transfrom.method = c("none","scale","center","log2","log10","ln",
                       "rrarefy","rrarefy_relative"),
  method = c("WGCNA","SpiecEasi","SPARCC","cor"),   # NOTE: no "Hmisc"
  cor.method = c("pearson","kendall","spearman"),
  SpiecEasi.method = c("mb","glasso"),
  nr_thresholds = 51, interval = NULL,
  unfold.method = c("gaussian","spline"), bandwidth = "nrd0", nr.fit.points = 51,
  discard.outliers = TRUE, discard.zeros = TRUE,
  min.mat.dim = 40, max.ev.spacing = 3,
  save_plots = FALSE, out_dir = "RMT_plots", verbose = TRUE, seed = 1115
)
```
Returns list: `chosen_threshold`, `chosen_reason`, `tested_thresholds`, `scores`
(data.frame), `unfolded`, `meta`, `plots`.

### get_network_topology
```r
get_network_topology(
  graph_obj = NULL, graph_obj_list = NULL, mat = NULL, graph_mat_list = NULL,
  transfrom.method = c("none","scale","center","log2","log10","ln",
                       "rrarefy","rrarefy_relative"),
  r.threshold = 0.7, p.threshold = 0.05,
  method = c("WGCNA","SpiecEasi","SPARCC","cor"),
  cor.method = c("pearson","kendall","spearman"),
  proc = c("holm","hochberg","hommel","bonferroni","BH","BY","fdr","none"),
  SpiecEasi.method = c("mb","glasso"), sparcc_R = 20, bootstrap = 100
)
```
Returns a **list**: `$topology` (data.frame of network-level metrics) and
`$Robustness`. Provide `mat` to get cohesion/robustness/stability — otherwise
`Cohension_Positive/Negative`, `Robustness_*`, `Stability` are `NA`.
`get_network_topology_parallel(..., parallel = TRUE, n_workers = 2)` is the parallel
variant. Pass `graph_obj_list = list(g1, g2)` (with the same analysis args) to compute
topology for several graphs in one call.

### get_node_centrality / get_node_ivi
```r
get_node_centrality(
  graph_obj,
  measures = c("Betweenness","Closeness","Eigenvector","PageRank","Hub_score",
               "Authority_score","Coreness","Harmonic"),   # or "all"
  weighted = FALSE, overwrite = TRUE
)

get_node_ivi(graph_obj, weights = NULL, mode = c("all","in","out"),
             directed = FALSE, d = 3, scale = c("range","z-scale","none"), ncores = 1L)
```
`get_node_centrality` **returns the augmented `tbl_graph`** (with the centrality
columns added) — assign the result: `g <- get_node_centrality(g)`.
`get_node_ivi` requires the Suggests-only `influential` package.

### ggNetView_multi_link
Build one sub-network per group and draw cross-group links/comparisons.
```r
ggNetView_multi_link(
  mat, group_info,                       # group_info: data.frame, e.g. Sample + Group
  transfrom.method = "none",
  r.threshold = 0.7, p.threshold = 0.05,
  method = "WGCNA", cor.method = "pearson", proc = "BH",
  module.method = "Fast_greedy",
  layout = "gephi", layout.module = "adjacent",
  center = TRUE, top_modules = 15, shrink = 0.5,
  jitter = TRUE, jitter_sd = 0.3, anchor_dist = 30,
  seed = 1115, orientation = "up", angle = 0,
  # circular-comparison extras:
  scale_groups = TRUE, dropOthers = TRUE, link_level = "Module&Node2",
  comparisons = TRUE, comparisons_groups = list(c("WT","KO")),
  order = c("WT","KO","OE")             # MUST enumerate ALL groups, case-sensitive
)
```
Returns list: `$p` (ggplot) and `$info` (per-group stats). Group names are
case-sensitive; `order` / `comparisons_groups` must reference existing groups.

### trans_TOM_in_WGCNA / build_graph_from_wgcna
```r
# threshold: drop edges with abs(weight) <= threshold (TOM is on a 0–1 scale)
# top_k:     keep each node's top-k strongest edges (mutual-kNN union; 10–30 typical)
# the two can be combined to sparsify
trans_TOM_in_WGCNA(TOM, mat, threshold = NULL, top_k = NULL)   # → long edge df (from,to,weight)

build_graph_from_wgcna(
  wgcna_tom,              # long-format edge df from trans_TOM_in_WGCNA()
  module = NULL,          # data.frame with EXACTLY columns: ID, Module
  node_annotation = NULL,
  directed = FALSE,
  seed = 1115
)
```
`trans_TOM_in_WGCNA`'s `mat` must match the orientation given to `WGCNA::adjacency()`
(samples in ROWS); it uses `colnames(mat)` as node IDs. `build_graph_from_wgcna` does
NOT recompute communities — it uses the supplied WGCNA module colours as `Modularity`.

### export_ggnetview
```r
export_ggnetview(plot, filename, width = 8, height = 8, ...)   # save a ggNetView ggplot
```

### ggnetview_zipi
Zi-Pi keystone-role classification. Takes a **node table + adjacency matrix**, NOT
a graph. `modularity_col` / `degree_col` are required (positional).
```r
ggnetview_zipi(
  nodes_bulk,            # data.frame from get_graph_nodes(); IDs in rownames or a `name` col
  z_bulk_mat,            # adjacency/correlation matrix from get_graph_adjacency()
  modularity_col,        # e.g. "Modularity"
  degree_col,            # e.g. "Degree"
  zi_threshold = 2.5,
  pi_threshold = 0.62,
  na.rm = FALSE
)
```
Returns list: `$data` (nodes + `within_module_connectivities`,
`among_module_connectivities`, `type`) and `$plot` (Zi-Pi quadrant ggplot).
Roles: module hubs / connectors / network hubs / peripherals.

(`get_node_centrality` / `get_node_ivi` signatures are above; both return an
augmented `tbl_graph` — assign the result. `get_node_ivi` needs the Suggests-only
`influential` package; use `scale = "z-scale"` for cross-network comparison.)

### Mantel + heatmap link figure
`gglink_heatmaps()` is the user-facing "Mantel/correlation + heatmap" plotter; the
`mantel_*` functions are the raw stats it wraps. `env`/`spec` are **samples × variables**
data frames with **matching row order**.
```r
gglink_heatmaps(
  env, spec,
  env_select,                      # named list; ONE heatmap quadrant per element
  spec_select,                     # named list; ONE central network per element
  relation_method = c("correlation","mantel"),
  mantel_kind = c("block_vs_col","col_vs_col"),  # block_vs_col = ecological standard
  spec_dist_method = "bray", env_dist_method = "euclidean",
  spec_collapse = FALSE, drop_nonsig = FALSE,
  comparisons = TRUE, comparisons_groups = NULL,  # restrict (env_block, spec_block) pairs
  link_color_by = "Correlation", link_width_by = "-log10(Pvalue)", SigLineMid = NULL,
  orientation = c("top_right","bottom_right","top_left","bottom_left"),
  group_layout = "circle", ...    # many styling args — see the package man page
)
```
Returns a **list of 3**: `[[1]]` straight-link ggplot, `[[2]]` curved-link ggplot,
`[[3]]` stats data.frame (`ID, Type, Correlation, Pvalue, p_signif, spec_block,
env_block, method`). `length(env_select)` must equal `length(orientation)`.
`ggnetview_modularity_heatmaps()` is the modularity-based sibling with the same
Mantel API. Raw helpers:
```r
mantel_block_vs_col(spec_df, env_df, block_name = "block",
  method = "pearson", spec_dist_method = "bray", env_dist_method = "euclidean",
  permutations = 999L)                       # → ID, Type, Correlation, Pvalue
mantel_pairwise(spec_df, env_df, method = "pearson", ...)        # col-vs-col variant
mantel_between_blocks(spec, env, spec_select, env_select, test_type = "mantel", ...)
```

### build_graph_from_double_mat / _with_module / multi_mat
Cross-correlate matrices into one (multipartite) graph. All matrices: **variables in
ROWS, the SAME samples in COLUMNS**. No `r/p` threshold — every cross-correlation
becomes an edge (degree-0 nodes dropped); pre-filter dense inputs.
```r
build_graph_from_double_mat(mat1, mat2,
  module.method = "Fast_greedy", node_annotation = NULL,
  directed = FALSE, top_modules = 15, seed = 1115)   # Modularity = community detection

build_graph_from_double_mat_with_module(mat1, mat2,
  node_annotation,            # REQUIRED: first col = node ID, plus a `Modularity` column
  directed = FALSE, top_modules = 15, seed = 1115)   # Modularity = your supplied labels

build_graph_from_multi_mat(mat1, mat2, ...,          # 3+ matrices
  module.method = "Fast_greedy", node_annotation = NULL,
  directed = FALSE, top_modules = 15, seed = 1115)
```
For a clean bipartite/tripartite split by omics, the layout splits on `Modularity`
and needs **exactly 2 / 3 levels** — use the `_with_module` variant with a 2-level
`Modularity`, then `ggNetView(layout = "bipartite_gephi_layout", layout.module = "order")`.

### build_graph_from_node_edge
Two-table interface; the `node` table is authoritative (isolated nodes are kept,
unlike `build_graph_from_df`).
```r
build_graph_from_node_edge(node, edge,   # node: col1 = ID; edge: first 2 cols = from,to
  directed = FALSE, module.method = "Fast_greedy", top_modules = 15, seed = 1115)
```

### get_subgraph / get_sample_subgraph / get_sample_subgraph_topology
```r
get_subgraph(graph_obj, select_module = NULL)   # select_module: character vector of module names
# → list: $sub_graph_all (per-module list), $sub_graph_select (selected modules), $stat_module

get_sample_subgraph(graph_obj, mat, min_abundance = 0,
  select_sample = NULL, combine = c("union","intersect"))
# present = mat[OTU, sample] > min_abundance (0 for counts, ~0.001 for relative abundance)
# → list: $sub_graph_all (per-sample), $stat_sample, $sub_graph_select (merged selected)

get_sample_subgraph_topology(graph_obj, mat = NULL, transfrom.method = "none",
  r.threshold = 0.7, p.threshold = 0.05, method = "WGCNA", cor.method = "pearson",
  proc = "bonferroni", bootstrap = 100)   # pass the SAME analysis args used to build graph_obj
# → list: $subgraph_list, $topology, $Robustness, $sample_stat
```

## Spelling quirks preserved from source (do not "fix")
- Argument `transfrom.method` (not "transform")
- Topology columns `Cohension_*` (not "Cohesion"), `Random_nerwork`
- Function `build_graph_from_enrichGO` (GO capitalized)

## Required setup
```r
library(tidyverse)   # manual examples load this for piping/dplyr
library(ggNetView)
# library(igraph)    # only when building from an igraph object
```
Key deps (auto-imported): tidygraph, ggraph, ggplot2, igraph, WGCNA, vegan, psych,
Hmisc, dplyr, Rcpp/RcppArmadillo. `R >= 4.2`. For deterministic WGCNA builds call
`WGCNA::disableWGCNAThreads()`. Reproducibility relies on `seed` (default `1115`).
