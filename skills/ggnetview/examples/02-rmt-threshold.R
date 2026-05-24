## ggNetView example 2 — RMT threshold selection, then build the graph
## RMT only recommends a cutoff; keep method/cor.method/transfrom.method identical
## between the RMT scan and build_graph_from_mat().

library(ggNetView)
library(ggplot2)

data("otu_rare_relative"); data("tax_tab")

N_OTU <- 150
keep  <- order(rowSums(otu_rare_relative), decreasing = TRUE)[seq_len(min(N_OTU, nrow(otu_rare_relative)))]
mat   <- otu_rare_relative[keep, , drop = FALSE]
tax   <- tax_tab[match(rownames(mat), tax_tab$OTUID), , drop = FALSE]

dir.create("figures", showWarnings = FALSE)

out <- ggNetView_RMT(
  mat              = mat,
  transfrom.method = "none",
  method           = "WGCNA",     # note: ggNetView_RMT does NOT accept "Hmisc"
  cor.method       = "pearson",
  unfold.method    = "gaussian",
  bandwidth        = "nrd0",
  discard.outliers = TRUE,
  discard.zeros    = TRUE,
  min.mat.dim      = 40,
  max.ev.spacing   = 3,
  verbose          = FALSE,
  seed             = 1115
)
message("RMT chosen_threshold = ", round(out$chosen_threshold, 4))

graph_obj <- build_graph_from_mat(
  mat              = mat,
  transfrom.method = "none",
  r.threshold      = out$chosen_threshold,   # data-driven cutoff
  p.threshold      = 0.05,
  method           = "WGCNA",
  cor.method       = "pearson",
  proc             = "bonferroni",
  module.method    = "Fast_greedy",
  node_annotation  = tax,
  top_modules      = 15,
  seed             = 1115
)

ggsave("figures/02-rmt-network.png",
       ggNetView(graph_obj, layout = "stress", fill.by = "Modularity", seed = 1115),
       width = 7, height = 7)

message("OK 02: threshold ", round(out$chosen_threshold, 4), " -> ",
        igraph::vcount(graph_obj), " nodes / ", igraph::ecount(graph_obj), " edges")
