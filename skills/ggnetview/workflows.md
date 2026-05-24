# ggNetView Workflows

Six end-to-end, copy-pasteable workflows. Every workflow follows the same grammar:
`build_graph_from_*()` → `ggNetView(layout = "…")` → optional scales/theme → export.
All examples assume `library(tidyverse); library(ggNetView)`.

The example datasets (`otu_rare_relative`, `tax_tab`, `otu_sample`,
`adjacency_matrix_example`) are bundled with the package and used here for
illustration — substitute your own data, and use your real group names (any literal
group strings like `"WT"` below are placeholders).

---

## 1. Network from a correlation / adjacency matrix

```r
data("otu_rare_relative")   # variables in ROWS, samples in COLUMNS
data("tax_tab")             # node annotation; first column = node ID

graph_obj <- build_graph_from_mat(
  mat              = otu_rare_relative,
  transfrom.method = "none",
  r.threshold      = 0.7,
  p.threshold      = 0.05,
  method           = "WGCNA",
  cor.method       = "pearson",
  proc             = "bonferroni",
  module.method    = "Fast_greedy",
  node_annotation  = tax_tab,
  top_modules      = 15,
  seed             = 1115
)

p <- ggNetView(
  graph_obj     = graph_obj,
  layout        = "gephi",
  layout.module = "adjacent",
  group.by      = "Modularity",
  fill.by       = "Modularity",
  center        = FALSE,
  shrink        = 0.9,
  linealpha     = 0.2
)
p
```

If you already have an adjacency matrix, swap the builder:
```r
graph_obj <- build_graph_from_adj_mat(
  adjacency_matrix = adjacency_matrix_example,
  module.method    = "Fast_greedy",
  node_annotation  = tax_tab,
  top_modules      = 15,
  seed             = 1115
)
# then the same ggNetView() call
```

---

## 2. RMT (random matrix theory) threshold selection

RMT only *recommends* a cutoff; you then build the graph with it. Keep
`method` / `cor.method` / `transfrom.method` identical between the two calls.

```r
out <- ggNetView_RMT(
  mat              = otu_rare_relative,
  transfrom.method = "none",
  method           = "WGCNA",
  cor.method       = "pearson",
  unfold.method    = "gaussian",
  bandwidth        = "nrd0",
  discard.outliers = TRUE,
  discard.zeros    = TRUE,
  min.mat.dim      = 40,
  max.ev.spacing   = 3,
  verbose          = TRUE,
  seed             = 1115
)
out$chosen_threshold

graph_obj <- build_graph_from_mat(
  mat              = otu_rare_relative,
  transfrom.method = "none",
  r.threshold      = out$chosen_threshold,   # data-driven cutoff
  p.threshold      = 0.05,
  method           = "WGCNA",
  cor.method       = "pearson",
  proc             = "bonferroni",
  module.method    = "Fast_greedy",
  node_annotation  = tax_tab,
  top_modules      = 15,
  seed             = 1115
)
```

---

## 3. Network topology metrics

`get_network_topology()` returns a **list**. Pass `mat` to unlock cohesion /
robustness / stability (otherwise they are `NA`).

```r
graph_obj <- build_graph_from_mat(
  otu_rare_relative, transfrom.method = "none", method = "WGCNA",
  proc = "bonferroni", r.threshold = 0.7, p.threshold = 0.05,
  node_annotation = tax_tab, top_modules = 15, seed = 1115
)

topo <- get_network_topology(
  graph_obj = graph_obj,
  mat       = otu_rare_relative,
  transfrom.method = "none", method = "WGCNA", proc = "bonferroni",
  r.threshold = 0.7, p.threshold = 0.05, bootstrap = 100
)
topo$topology     # network-level metrics (data.frame)
topo$Robustness   # node-removal robustness curve

# Per-node centralities (adds columns to the tbl_graph):
graph_aug <- get_node_centrality(graph_obj)
```

---

## 4. A specific deterministic layout

Pass the layout name as a string; do not call `create_layout_*`. `"stress"` is the
recommended reproducible, publication-quality layout.

```r
p <- ggNetView(
  graph_obj     = graph_obj,
  layout        = "stress",          # try also: "fr", "kk", "gephi", "circle"
  center        = FALSE,
  shrink        = 0.8,
  layout.module = "adjacent",
  group.by      = "Modularity",
  fill.by       = "Modularity",
  seed          = 1115               # same graph + seed + layout = same figure
)
p
```

Module/multipartite layouts need the literal `_layout` suffix and `layout.module
= "order"`:
```r
ggNetView(graph_obj, layout = "circular_modules_equal_gephi_layout",
          layout.module = "order", fill.by = "Modularity", seed = 1115)
```

---

## 5. Compare networks across groups

```r
data("otu_rare_relative")
data("otu_sample")   # has Sample + Group columns

out <- ggNetView_multi_link(
  mat              = otu_rare_relative,
  group_info       = otu_sample,
  transfrom.method = "none",
  r.threshold      = 0.7, p.threshold = 0.05,
  method           = "WGCNA", cor.method = "pearson", proc = "BH",
  module.method    = "Fast_greedy",
  layout           = "gephi", layout.module = "adjacent",
  center           = TRUE, top_modules = 15, shrink = 0.5,
  scale_groups     = FALSE,        # keep each group's native size (NOT "scale")
  jitter           = TRUE, jitter_sd = 0.3, anchor_dist = 30,
  seed             = 1115, orientation = "up", angle = 0
)
p <- out[["p"]]   # assembled ggplot
out$info          # per-group node/edge/module counts
```

With explicit comparison brackets (circular layout, case-sensitive group names —
`order` must list ALL groups). **`"WT"/"KO"/"OE"` below are placeholders** — replace
them with your real groups, e.g. `unique(otu_sample$Group)`, or you'll hit a
case-sensitive `order` error:
```r
grp <- unique(otu_sample$Group)   # use the ACTUAL group names

out <- ggNetView_multi_link(
  mat = otu_rare_relative, group_info = otu_sample,
  method = "WGCNA", cor.method = "pearson", proc = "BH",
  layout = "circular_modules_equal_gephi_layout", layout.module = "order",
  scale_groups = TRUE, dropOthers = TRUE, link_level = "Module&Node2",
  comparisons = TRUE, comparisons_groups = list(grp[1:2]),
  order = grp, seed = 1115
)
```

For a purely numeric comparison of two graphs, use
`get_network_topology(graph_obj_list = list(g1, g2))`.

---

## 6. WGCNA network

**Route A — quick** (just set `method = "WGCNA"`):
```r
graph_obj <- build_graph_from_mat(otu_rare_relative, method = "WGCNA",
  transfrom.method = "none", proc = "bonferroni",
  r.threshold = 0.7, p.threshold = 0.05,
  node_annotation = tax_tab, top_modules = 15, seed = 1115)
ggNetView(graph_obj, layout = "stress", fill.by = "Modularity", seed = 1115)
```

**Route B — full classic WGCNA pipeline** (TOM → edge list → graph):
```r
library(ggNetView)
WGCNA::disableWGCNAThreads()

expr_mat <- t(mat)   # WGCNA wants samples in ROWS, features in COLUMNS
sft <- WGCNA::pickSoftThreshold(expr_mat, powerVector = c(1:10, seq(12, 30, 2)),
                                networkType = "signed", verbose = 0)
power <- sft$powerEstimate; if (is.na(power)) power <- 6

adjacency <- WGCNA::adjacency(expr_mat, power = power, type = "signed",
  corFnc = "cor", corOptions = list(method = "spearman", use = "pairwise.complete.obs"))
TOM     <- WGCNA::TOMsimilarity(adjacency, TOMType = "signed")
dissTOM <- 1 - TOM
tree    <- hclust(as.dist(dissTOM), method = "average")
mods    <- dynamicTreeCut::cutreeDynamic(dendro = tree, distM = dissTOM,
              deepSplit = 2, minClusterSize = 5)

module_df <- data.frame(ID = colnames(expr_mat),
                        Module = WGCNA::labels2colors(mods),
                        stringsAsFactors = FALSE)

edge_df <- trans_TOM_in_WGCNA(TOM = TOM, mat = expr_mat, threshold = 0.1)  # or top_k = 20

graph_full <- build_graph_from_wgcna(
  wgcna_tom       = edge_df,
  module          = module_df,     # EXACTLY columns ID + Module
  node_annotation = annot,
  seed            = 1
)

ggNetView(graph_full, layout = "WGCNA", layout.module = "order",
          fill.by = "Modularity", seed = 1)
```

`module` must be a data.frame with exactly `ID` and `Module` columns. `layout =
"WGCNA"` is the dedicated bubble-pack layout (and the only one honoring
`inner_shrink`).
