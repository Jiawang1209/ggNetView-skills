# ggNetView Troubleshooting

## Hallucinated name → real name

A model with no ggNetView training will invent ggraph/igraph-style names. These are
the actual replacements:

| Hallucinated | Real |
|---|---|
| `as_netview()`, `netview()`, `build_network()` | `build_graph_from_mat()` / `build_graph_from_adj_mat()` |
| `ggnetview()` (lowercase), `plot(net)`, `autoplot(net)` | `ggNetView()` (camelCase) |
| `rmt_threshold()`, `rmt()`, `select_threshold_rmt()` | `ggNetView_RMT()` |
| `network_metrics()`, `node_metrics()`, `topology()` | `get_network_topology()`, `get_node_centrality()` |
| `compare_networks()`, `diff_networks()`, `ggnetview_compare()` | `ggNetView_multi_link()` |
| `wgcna_network()` | `build_graph_from_mat(method="WGCNA")` / `build_graph_from_wgcna()` |
| `create_layout_stress(g)` | `ggNetView(g, layout = "stress")` |
| `color_by = "module"` | `fill.by = "Modularity"` / `group.by = "Modularity"` |
| `net_zipi()`, `zi_pi()`, `plot_zipi()` | `ggnetview_zipi(nodes, adj, "Modularity", "Degree")` |
| `net_centrality()`, `net_hub()`, `node_importance()` | `get_node_centrality()`, `get_node_ivi()` |
| `ggNet_mantel()`, `mantel_test()`, `ggcor()` | `gglink_heatmaps(relation_method = "mantel")`, `mantel_block_vs_col()` |
| `ggNetCorr()`, `ggNetBuild()`, `cross_correlate()` | `build_graph_from_double_mat()` / `build_graph_from_multi_mat()` |
| `layout = "bipartite"`, `"tripartite"` | `layout = "bipartite_gephi_layout"` / `"tripartite_gephi_layout"` |
| `subNetwork()`, `induced_subgraph()`, `netTopology()` | `get_subgraph()`, `get_sample_subgraph()`, `get_sample_subgraph_topology()` |

## Common errors and fixes

**`could not find function "ggnetview"` (or any guessed name)**
You used a non-existent name. The main plotter is `ggNetView()` (capital N, V). Build
the graph first with a `build_graph_from_*()` function. See api-reference.md.

**`unused argument (transform.method = ...)`**
The argument is spelled `transfrom.method` (typo preserved in source). Same family of
quirks: output columns `Cohension_*`, `Random_nerwork`.

**`'arg' should be one of "WGCNA", "SpiecEasi", ...`**
`method` is case-sensitive: `"WGCNA"`, `"SpiecEasi"`, `"SPARCC"`, `"cor"`, `"Hmisc"`.
Note `ggNetView_RMT()` and `get_network_topology()` do **not** accept `"Hmisc"`.

**`could not find function "create_layout_stress"` / layout doesn't apply**
`create_layout_*` are internal. Pass the suffix as a string:
`ggNetView(g, layout = "stress")`. For module/multipartite layouts include the
literal `_layout` suffix and set `layout.module = "order"`.

**Topology results are all `NA` (cohesion / robustness / stability)**
`get_network_topology()` needs `mat` to compute those. Pass the original matrix:
`get_network_topology(graph_obj = g, mat = my_mat, ...)`.

**`$ operator is invalid for atomic vectors` after topology**
`get_network_topology()` returns a **list**, not a data.frame. Use `result$topology`.

**Empty / wrong graph: nodes are samples instead of features**
Matrix orientation. `build_graph_from_mat` / `ggNetView_RMT` / `get_network_topology`
expect **variables in rows, samples in columns**. WGCNA's own `adjacency()` /
`pickSoftThreshold()` expect the opposite (samples in rows) — transpose with `t()`
when crossing between them.

**Non-reproducible figures between runs**
Set `seed` (default `1115`) on every builder and plotting call. Prefer deterministic
layouts (`"stress"`). For WGCNA determinism also call `WGCNA::disableWGCNAThreads()`.

**`ggNetView_multi_link` errors on `order` / `comparisons_groups`**
Group names are case-sensitive and `order` must enumerate **all** unique groups in
`group_info$Group` (e.g. `order = unique(group_info$Group)`). Result is a list — use
`out$p` (plot) and `out$info` (stats).

**`ggNetView_multi_link` silently ignores your `scale` setting**
`ggNetView_multi_link()` has NO `scale` argument (that belongs to single-plot
`ggNetView()`). Writing `scale = FALSE` does not error — R partial-matches it to
`scale_groups`, silently changing behavior. Use `scale_groups` explicitly.

**`build_graph_from_wgcna` rejects `module`**
`module` must be a data.frame with exactly columns `ID` and `Module`. From a WGCNA
`net`: `data.frame(ID = names(net$colors), Module = as.character(net$colors))`.

**`could not find function "get_node_ivi"` works but errors internally**
`get_node_ivi()` requires the Suggests-only `influential` package — install it.

**`ggnetview_zipi()` errors on a graph object / missing `modularity_col`**
It is not a graph plotter. Pass the **node table** and the **adjacency matrix**:
`ggnetview_zipi(get_graph_nodes(g), get_graph_adjacency(g), "Modularity", "Degree")`.
`modularity_col` and `degree_col` are required positional args. Read roles from
`$data$type`; the figure is `$plot`.

**Centrality columns disappear after `get_node_centrality()`**
It returns a NEW augmented `tbl_graph` — assign it: `g <- get_node_centrality(g)`.
Same for `get_node_ivi()` (adds an `IVI` column).

**`gglink_heatmaps()` "result is not a ggplot" / can't `+ theme()`**
It returns a **list of 3**: `out[[1]]` straight links, `out[[2]]` curved links,
`out[[3]]` the stats data.frame. Add ggplot layers to `out[[1]]`/`out[[2]]`, not `out`.
Also: `env`/`spec` must share row order, and `length(env_select)` must equal
`length(orientation)`. For the ecological Mantel use `mantel_kind = "block_vs_col"`.

**Bipartite/tripartite layout error: "requires at least/exactly 2/3 modules in `Modularity`"**
These layouts split on the `Modularity` column. `build_graph_from_double_mat()` fills
`Modularity` from community detection (any number of groups). For a clean omics split,
use `build_graph_from_double_mat_with_module()` with a `node_annotation` whose first
column is the node ID and which has a `Modularity` column of exactly 2 (bipartite) or
3 (tripartite) levels; then `ggNetView(layout = "bipartite_gephi_layout",
layout.module = "order")`.

**Multi-omics network is hopelessly dense**
`build_graph_from_double_mat()` has no `r.threshold`/`p.threshold` — it keeps every
cross-correlation as an edge. Pre-filter `mat1`/`mat2` (e.g. top-variance or abundant
features) before building.

**`$ operator is invalid` / wrong object after `get_subgraph` or `get_sample_subgraph`**
Both return lists. The extracted graph is `$sub_graph_select`; per-module/per-sample
graphs are in `$sub_graph_all`; summaries are `$stat_module` / `$stat_sample`.

**`get_subgraph()` errors: `'names' attribute [N] must be the same length as the vector [M]`**
`get_subgraph()` expects every level of the `Modularity` factor to be populated. The
builders always append an `"Others"` level, which is filled only when the network has
**more** modules than `top_modules` (the usual case — then `get_subgraph()` just works).
If the network has **≤ `top_modules`** modules, `"Others"` stays empty and the level
count no longer matches the populated groups. Fix from your side — drop the unused
level before calling (works for any module count):
`graph_obj <- graph_obj %>% tidygraph::activate("nodes") %>% tidygraph::mutate(Modularity = droplevels(Modularity))`
— or set `top_modules` below the actual module count.

## When unsure

Don't guess names. The exported-function list and signatures in **api-reference.md**
are authoritative; the six **workflows.md** examples are known-correct templates.
