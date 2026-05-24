## ggNetView example 1 — build a network from a matrix and plot it
## Demo runs on a subset; set N_OTU <- Inf (or delete the subset block) for full data.

library(ggNetView)
library(ggplot2)

data("otu_rare_relative"); data("tax_tab"); data("adjacency_matrix_example")

N_OTU <- 150
keep  <- order(rowSums(otu_rare_relative), decreasing = TRUE)[seq_len(min(N_OTU, nrow(otu_rare_relative)))]
mat   <- otu_rare_relative[keep, , drop = FALSE]
tax   <- tax_tab[match(rownames(mat), tax_tab$OTUID), , drop = FALSE]

dir.create("figures", showWarnings = FALSE)

## --- correlation network from a feature x sample matrix ---
graph_obj <- build_graph_from_mat(
  mat              = mat,
  transfrom.method = "none",      # source spelling: "transfrom"
  r.threshold      = 0.6,
  p.threshold      = 0.05,
  method           = "WGCNA",     # case-sensitive: WGCNA/SpiecEasi/SPARCC/cor/Hmisc
  cor.method       = "pearson",
  proc             = "bonferroni",
  module.method    = "Fast_greedy",
  node_annotation  = tax,         # first column = node ID
  top_modules      = 15,
  seed             = 1115
)

p <- ggNetView(
  graph_obj, layout = "stress", layout.module = "adjacent",
  group.by = "Modularity", fill.by = "Modularity",
  center = FALSE, shrink = 0.9, linealpha = 0.2, seed = 1115
)
ggsave("figures/01-network-stress.png", p, width = 7, height = 7)

## --- alternative: from a pre-built adjacency matrix ---
adj   <- adjacency_matrix_example[seq_len(N_OTU), seq_len(N_OTU)]
g_adj <- build_graph_from_adj_mat(
  adjacency_matrix = adj, module.method = "Fast_greedy",
  top_modules = 15, seed = 1115
)
ggsave("figures/01-network-from-adj.png",
       ggNetView(g_adj, layout = "stress", fill.by = "Modularity", seed = 1115),
       width = 7, height = 7)

message("OK 01: ", igraph::vcount(graph_obj), " nodes / ",
        igraph::ecount(graph_obj), " edges; figures written")
