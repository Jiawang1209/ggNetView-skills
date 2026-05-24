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

## When unsure

Don't guess names. The exported-function list and signatures in **api-reference.md**
are authoritative; the six **workflows.md** examples are known-correct templates.
