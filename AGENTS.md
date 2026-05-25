# AGENTS.md — ggNetView guidance (Codex / cross-tool)

This repository packages a Claude Code **skill** for the [ggNetView](https://github.com/Jiawang1209)
R package. Claude Code auto-activates that skill from `skills/ggnetview/SKILL.md`
by its `description`. **Other agents (e.g. OpenAI Codex CLI) do not auto-activate
skills**, so this `AGENTS.md` carries the same guidance as always-on context.

**When the user is writing, debugging, or reviewing R code that uses ggNetView**
(any `library(ggNetView)`, or correlation / co-occurrence / WGCNA / SpiecEasi /
SparCC network analysis and visualization), follow the rules below and read the
detailed reference files before generating code.

## The three rules that prevent almost every error

1. The main plotting function is **`ggNetView()`** — capital N, capital V. Not
   `ggnetview()`, not `as_netview()`, not `plot()`.
2. The **layout is a STRING**: `ggNetView(layout = "stress")`. The `create_layout_*`
   functions are **internal** — never call them directly.
3. Build the graph **first** with a `build_graph_from_*()` function; `ggNetView()`
   only renders an existing graph object.

ggNetView is a niche package whose API does **not** follow ggraph/igraph naming. If
you "remember" a ggNetView function name, you are probably hallucinating it — copy
names from `skills/ggnetview/api-reference.md` instead of guessing.

## Guessed-wrong → actually-correct (high-frequency)

| If you reach for… | Use instead |
|---|---|
| `ggnetview(...)` / `as_netview(...)` / `plot(net)` | `build_graph_from_mat(...)` then `ggNetView(graph_obj, ...)` |
| `rmt_threshold(...)` | `ggNetView_RMT(...)$chosen_threshold` |
| `network_metrics()` / `topology()` | `get_network_topology(...)$topology` (returns a **list**) |
| `compare_networks()` | `ggNetView_multi_link(...)$p` |
| `net_zipi()` / `plot_zipi()` | `ggnetview_zipi(get_graph_nodes(g), get_graph_adjacency(g), "Modularity", "Degree")$plot` |
| `net_centrality()` / `net_hub()` | `get_node_centrality(g)` / `get_node_ivi(g)` (both **return** an augmented graph) |
| `ggNet_mantel()` → a ggplot | `gglink_heatmaps(relation_method = "mantel", mantel_kind = "block_vs_col")` (returns a **list of 3**) |
| `ggNetCorr()` / `ggNetBuild(bipartite = TRUE)` | `build_graph_from_double_mat(...)` → `ggNetView(layout = "bipartite_gephi_layout", layout.module = "order")` |
| `subNetwork()` / `netTopology()` | `get_subgraph(g, select_module = ...)` / `get_sample_subgraph_topology(g, mat = ...)` |
| `transform.method = ...` | `transfrom.method = ...` (source spelling — keep the typo) |

## Reference files (read these for detail)

- `skills/ggnetview/SKILL.md` — lean entry point: rules, quick-reference, canonical pipeline.
- `skills/ggnetview/api-reference.md` — authoritative exported-function list + signatures.
- `skills/ggnetview/workflows.md` — 10 copy-paste workflows (6 core + 4 advanced:
  Zi-Pi/hub, Mantel environment, multi-omics/bipartite, subgraph/per-sample).
- `skills/ggnetview/troubleshooting.md` — error message → fix.
- `skills/ggnetview/examples/` — runnable `.R` scripts (`01`–`10`).

## Top gotchas

- `transfrom.method` (typo preserved), output columns `Cohension_*`, `Random_nerwork`.
- `build_graph_from_mat` / `ggNetView_RMT` / `get_network_topology` want **variables
  in rows, samples in columns**; native WGCNA (`adjacency`, `pickSoftThreshold`) wants
  the opposite — transpose with `t()` when crossing between them.
- `method` is case-sensitive: `"WGCNA"`, `"SpiecEasi"`, `"SPARCC"`, `"cor"`, `"Hmisc"`.
- `seed` (default `1115`) drives reproducibility — set it on every builder/plot call.
- `gglink_heatmaps()` returns `list(straight_plot, curved_plot, stats_df)`.
- Bipartite/tripartite layouts split on `Modularity` and need exactly 2/3 levels —
  use `build_graph_from_double_mat_with_module()` for a clean omics split.

> Tool-name note: this skill is **knowledge-only** (no tool calls of its own), so no
> Claude→Codex tool mapping is needed — the guidance and code apply verbatim.
