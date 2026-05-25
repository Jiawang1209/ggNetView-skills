## ggNetView example 9 — multi-omics / bipartite network
## Two feature x sample matrices (SAME samples in columns) cross-correlated into one
## bipartite graph. The bipartite layout splits on `Modularity` and needs exactly 2
## levels — so the omics-vs-omics split uses build_graph_from_double_mat_with_module().
## (For the demo we split one OTU table into two disjoint feature blocks.)

library(ggNetView)
library(ggplot2)

data("otu_rare_relative")

keep <- order(rowSums(otu_rare_relative), decreasing = TRUE)[seq_len(min(60, nrow(otu_rare_relative)))]
sub  <- as.matrix(otu_rare_relative[keep, , drop = FALSE])
mat1 <- sub[1:30, , drop = FALSE]    # stand-in "omics 1"; variables in rows, samples in cols
mat2 <- sub[31:60, , drop = FALSE]   # stand-in "omics 2"; SAME samples (columns) as mat1

dir.create("figures", showWarnings = FALSE)

## Route A — colour by data-driven communities (no built-in r/p threshold: dense by design)
gA <- build_graph_from_double_mat(
  mat1 = mat1, mat2 = mat2, module.method = "Fast_greedy", seed = 1115
)
ggsave("figures/09-doublemat-gephi.png",
       ggNetView(gA, layout = "gephi", fill.by = "Modularity", seed = 1115),
       width = 7, height = 7)

## Route B — clean two-sided bipartite split BY OMICS.
## node_annotation: first column = node ID, plus a 2-level `Modularity` column.
annot <- data.frame(
  name       = c(rownames(mat1), rownames(mat2)),
  Modularity = c(rep("Omics1", nrow(mat1)), rep("Omics2", nrow(mat2))),
  stringsAsFactors = FALSE
)
gB <- build_graph_from_double_mat_with_module(
  mat1 = mat1, mat2 = mat2, node_annotation = annot, seed = 1115
)
ggsave("figures/09-bipartite.png",
       ggNetView(gB, layout = "bipartite_gephi_layout",  # literal _layout suffix
                 layout.module = "order",                # required by multipartite layouts
                 fill.by = "Modularity", seed = 1115),
       width = 7, height = 7)

message("OK 09: double-matrix + bipartite figures written (",
        igraph::vcount(gB), " nodes / ", igraph::ecount(gB), " edges)")
