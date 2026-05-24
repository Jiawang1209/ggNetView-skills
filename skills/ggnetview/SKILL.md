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
| `transform.method = ...` | `transfrom.method = ...` (source spelling — keep the typo) |

## Quick Reference — task → function

| Task | Function(s) |
|---|---|
| Graph from correlation matrix | `build_graph_from_mat()` → `ggNetView()` |
| Graph from adjacency matrix | `build_graph_from_adj_mat()` → `ggNetView()` |
| RMT threshold selection | `ggNetView_RMT()` (returns `$chosen_threshold`) |
| Topology / robustness | `get_network_topology()` (returns list `$topology`, `$Robustness`) |
| Node centrality / IVI / Zi-Pi | `get_node_centrality()`, `get_node_ivi()`, `ggnetview_zipi()` |
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

End-to-end examples for all 6 common tasks: **workflows.md**.

## Common Mistakes

- **Inventing function names.** The #1 failure. ggNetView's API does not follow ggraph/igraph naming. Check api-reference.md.
- **Calling `create_layout_*` directly.** They are internal; pass the suffix as `layout = "..."` to `ggNetView()`.
- **`transform.method`.** The real argument is `transfrom.method` (typo preserved in source). Same for output columns: `Cohension_*` (not "Cohesion"), `Random_nerwork`.
- **Wrong matrix orientation.** `build_graph_from_mat` / `ggNetView_RMT` / `get_network_topology` want **variables in rows, samples in columns**. Native WGCNA functions (`adjacency`, `pickSoftThreshold`) want the opposite (samples in rows).
- **Treating topology output as a data.frame.** It's a list — use `$topology`. With `mat = NULL`, cohesion/robustness/stability come back `NA`.
- **RMT building the graph.** It doesn't — feed `out$chosen_threshold` into `build_graph_from_mat(r.threshold = ...)`, keeping `method`/`cor.method`/`transfrom.method` identical to the RMT scan.
- **Forgetting `seed`.** Default is `1115`. Omitting/changing it breaks reproducibility.

Error messages and fixes: **troubleshooting.md**.
