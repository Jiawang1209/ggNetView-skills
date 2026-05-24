## ggNetView example 4 — deterministic layouts
## The layout is a STRING passed to ggNetView(layout = "..."). Never call
## create_layout_* directly. Bare names for simple layouts; the "_layout" suffix +
## layout.module = "order" for module/multipartite layouts.

library(ggNetView)
library(ggplot2)

data("otu_rare_relative"); data("tax_tab")

N_OTU <- 150
keep  <- order(rowSums(otu_rare_relative), decreasing = TRUE)[seq_len(min(N_OTU, nrow(otu_rare_relative)))]
mat   <- otu_rare_relative[keep, , drop = FALSE]
tax   <- tax_tab[match(rownames(mat), tax_tab$OTUID), , drop = FALSE]

dir.create("figures", showWarnings = FALSE)

graph_obj <- build_graph_from_mat(
  mat, transfrom.method = "none", method = "WGCNA", proc = "bonferroni",
  r.threshold = 0.6, p.threshold = 0.05,
  node_annotation = tax, top_modules = 15, seed = 1115
)

## simple deterministic layout
ggsave("figures/04-stress.png",
       ggNetView(graph_obj, layout = "stress", layout.module = "adjacent",
                 fill.by = "Modularity", center = FALSE, shrink = 0.8, seed = 1115),
       width = 7, height = 7)

## module-aware layout: literal "_layout" suffix + layout.module = "order"
ggsave("figures/04-circular-modules.png",
       ggNetView(graph_obj, layout = "circular_modules_equal_gephi_layout",
                 layout.module = "order", fill.by = "Modularity", seed = 1115),
       width = 7, height = 7)

## WGCNA bubble-pack layout (the only one honoring inner_shrink)
ggsave("figures/04-wgcna-layout.png",
       ggNetView(graph_obj, layout = "WGCNA", layout.module = "order",
                 fill.by = "Modularity", inner_shrink = 0.8, seed = 1115),
       width = 7, height = 7)

message("OK 04: stress / circular_modules / WGCNA layouts written to figures/")
