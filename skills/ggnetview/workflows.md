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

---

## 7. Keystone taxa: Zi-Pi roles + hub nodes

Two complementary node-importance views. **Zi-Pi** (`ggnetview_zipi`) classifies
each node into module hub / connector / network hub / peripheral. **Centrality /
IVI** (`get_node_centrality`, `get_node_ivi`) rank nodes by influence.

`ggnetview_zipi()` does NOT take a graph — feed it the **node table** and the
**adjacency matrix** pulled off the graph. Its args are positional:
`(nodes_bulk, z_bulk_mat, modularity_col, degree_col)`; `modularity_col` and
`degree_col` are required (no defaults).

```r
graph_obj <- build_graph_from_mat(
  otu_rare_relative, transfrom.method = "none", method = "WGCNA",
  cor.method = "pearson", proc = "bonferroni",
  r.threshold = 0.7, p.threshold = 0.05, module.method = "Fast_greedy",
  node_annotation = tax_tab, top_modules = 15, seed = 1115
)

nodes_bulk <- get_graph_nodes(graph_obj)       # node table (has Modularity, Degree)
adj_mat    <- get_graph_adjacency(graph_obj)   # square adjacency matrix

zipi <- ggnetview_zipi(
  nodes_bulk, adj_mat,
  modularity_col = "Modularity",   # capital-M column added by the builder
  degree_col     = "Degree",
  zi_threshold   = 2.5,            # Guimera & Amaral defaults
  pi_threshold   = 0.62
)
zipi$data    # node table + within_module_connectivities, among_module_connectivities, type
zipi$plot    # ready-to-save Zi-Pi quadrant scatter (a ggplot)
```

Hub / influential nodes — both functions **return an augmented `tbl_graph`**, so
assign the result:

```r
graph_cent <- get_node_centrality(graph_obj)   # adds Betweenness, Hub_score, PageRank, ...
graph_cent %>% tidygraph::activate(nodes) %>% tibble::as_tibble() %>%
  dplyr::arrange(dplyr::desc(Hub_score)) %>% utils::head(10)

graph_ivi <- get_node_ivi(graph_obj)           # adds a single integrated IVI column
# get_node_ivi() needs the Suggests-only `influential` package:
#   install.packages("influential")
```

To colour a plot by a continuous score, bin it into a factor first (`fill.by` is
discrete): `cut(IVI, breaks = quantile(IVI, 0:4/4), ...)` then `fill.by = "IVI_bin"`.

---

## 8. Network vs environment: Mantel test + correlation heatmap

The popular "Mantel + heatmap" figure is one call to **`gglink_heatmaps()`** — a
central species network surrounded by up to four env-env correlation heatmaps,
with links coloured/sized by Mantel r / p. `env` and `spec` are **samples × variables**
data frames whose **row order must match**.

```r
data("Envdf_4st")   # environmental table: rows = samples, cols = env factors
data("Spedf")       # species table:       rows = samples (same order!), cols = species

out <- gglink_heatmaps(
  env  = Envdf_4st,
  spec = Spedf,
  env_select  = list(Env01 = 1:14, Env02 = 15:28,    # one heatmap quadrant per block;
                     Env03 = 29:42, Env04 = 43:56),  #   length MUST equal length(orientation)
  spec_select = list(Spec01 = 1:15, Spec02 = 16:30), # one central network per block
  relation_method  = "mantel",        # vs "correlation" (psych::corr.test links)
  mantel_kind      = "block_vs_col",  # ecologically meaningful default (whole spec block vs each env col)
  spec_dist_method = "bray",          # community distance (vegan::vegdist)
  env_dist_method  = "euclidean",
  spec_collapse    = TRUE,            # render each spec block as one labelled point
  drop_nonsig      = TRUE,            # hide non-significant links (kept in the stats table)
  link_color_by    = "Correlation",   # an expression string; pair with SigLineMid for diverging
  SigLineMid       = "white",
  orientation      = c("top_right", "bottom_right", "top_left", "bottom_left")
)

out[[1]]        # ggplot with STRAIGHT links
out[[2]]        # ggplot with CURVED links
head(out[[3]])  # full stats: ID, Type, Correlation, Pvalue, p_signif, spec_block, env_block, method
```

`gglink_heatmaps()` returns a **list of 3** (straight plot, curved plot, stats) —
not a single ggplot. Use `mantel_kind = "block_vs_col"` for the standard
"community-vs-environment" interpretation; `"col_vs_col"` is the legacy
single-column variant (close to a rank correlation).

For raw Mantel numbers without the figure, call the lower-level helpers directly
(`spec`/`env` = samples × variables):

```r
mantel_block_vs_col(spec_df = Spedf, env_df = Envdf_4st,   # whole community vs each env col
  spec_dist_method = "bray", env_dist_method = "euclidean", permutations = 999)
# → data.frame: ID, Type, Correlation (Mantel r), Pvalue
```

---

## 9. Multi-omics / bipartite networks

`build_graph_from_double_mat()` cross-correlates two feature×sample matrices
(**same samples in columns**, features in rows) into one bipartite network. Note
it keeps **all** cross-correlations (no `r.threshold` / `p.threshold` argument) —
pre-filter your features if the result is too dense.

**Route A — colour by data-driven communities** (general view):
```r
# mat1, mat2: variables in ROWS, the SAME samples in COLUMNS
g2 <- build_graph_from_double_mat(
  mat1 = microbe_mat, mat2 = metabolite_mat,
  module.method = "Fast_greedy", seed = 1115
)
ggNetView(g2, layout = "gephi", fill.by = "Modularity", seed = 1115)
```

**Route B — a clean two-sided bipartite split by omics.** The bipartite layout
splits on `Modularity` and needs **exactly 2 levels**. `build_graph_from_double_mat()`
sets `Modularity` from community detection (could be many groups), so for a true
omics-vs-omics split use the `_with_module` variant and supply a `node_annotation`
whose **first column is the node ID** and which carries a 2-level `Modularity`:

```r
annot <- data.frame(
  name       = c(rownames(microbe_mat), rownames(metabolite_mat)),  # node IDs (col 1)
  Modularity = c(rep("Microbe",    nrow(microbe_mat)),
                 rep("Metabolite", nrow(metabolite_mat)))           # exactly 2 levels
)
g2 <- build_graph_from_double_mat_with_module(
  mat1 = microbe_mat, mat2 = metabolite_mat,
  node_annotation = annot, seed = 1115
)
ggNetView(g2, layout = "bipartite_gephi_layout",  # NOTE the literal _layout suffix
          layout.module = "order",                # required by multipartite layouts
          fill.by = "Modularity", seed = 1115)
```

**Three omics → tripartite** (`build_graph_from_multi_mat`, `Modularity` = 3 levels):
```r
g3 <- build_graph_from_multi_mat(mat1, mat2, mat3, module.method = "Fast_greedy", seed = 1115)
ggNetView(g3, layout = "tripartite_gephi_layout", layout.module = "order",
          fill.by = "Modularity", seed = 1115)
```

---

## 10. Subgraphs: by module and per sample

Slice an existing graph without rebuilding it. Both extractors return a **list**.

```r
graph_obj <- build_graph_from_mat(
  otu_rare_relative, transfrom.method = "none", method = "WGCNA",
  cor.method = "pearson", proc = "bonferroni",
  r.threshold = 0.7, p.threshold = 0.05, module.method = "Fast_greedy",
  node_annotation = tax_tab, top_modules = 15, seed = 1115
)

# (a) by module — select_module is a character vector of module names.
# get_subgraph() needs every Modularity level populated. The builders append an
# "Others" level that is empty unless the network has MORE modules than top_modules;
# if it has <= top_modules modules (common on small/demo data), drop the empty level
# first (harmless when there is nothing to drop):
graph_obj <- graph_obj %>% tidygraph::activate("nodes") %>%
  tidygraph::mutate(Modularity = droplevels(Modularity))

sub <- get_subgraph(graph_obj, select_module = c("5", "2", "8"))
sub$stat_module        # Module, Number (per-module node counts of the FULL graph)
sub$sub_graph_select   # one tbl_graph with only modules 5/2/8 and their internal edges
ggNetView(sub$sub_graph_select, layout = "stress", fill.by = "Modularity", seed = 1115)

# (b) per sample — an OTU is "present" in a sample when mat[OTU, sample] > min_abundance
res <- get_sample_subgraph(
  graph_obj     = graph_obj,
  mat           = otu_rare_relative,
  min_abundance = 0,            # 0 for counts; ~0.001 for relative abundance
  select_sample = colnames(otu_rare_relative)[1:3],
  combine       = "union"       # "union" = present in ANY; "intersect" = core across all
)
res$stat_sample        # Sample, Node, Edge, Status (every sample, even empty ones)
res$sub_graph_all      # named list of per-sample tbl_graphs
res$sub_graph_select   # merged subgraph of the 3 selected samples
```

Compare topology across samples (re-runs `get_network_topology()` per sample —
pass the same analysis args + `mat`):

```r
st <- get_sample_subgraph_topology(
  graph_obj = graph_obj, mat = otu_rare_relative,
  transfrom.method = "none", method = "WGCNA", proc = "bonferroni",
  r.threshold = 0.7, p.threshold = 0.05, bootstrap = 100
)
st$topology      # per-sample topology table
st$sample_stat   # per-sample node/edge counts + status
