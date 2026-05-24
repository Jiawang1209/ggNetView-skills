## ggNetView example 6 — WGCNA networks (two routes)
## Route A: just method = "WGCNA" in build_graph_from_mat().
## Route B: classic WGCNA TOM -> trans_TOM_in_WGCNA() -> build_graph_from_wgcna().

library(ggNetView)
library(ggplot2)

data("otu_rare_relative"); data("tax_tab")

N_OTU <- 150
keep  <- order(rowSums(otu_rare_relative), decreasing = TRUE)[seq_len(min(N_OTU, nrow(otu_rare_relative)))]
mat   <- as.matrix(otu_rare_relative[keep, , drop = FALSE])    # features x samples
tax   <- tax_tab[match(rownames(mat), tax_tab$OTUID), , drop = FALSE]

dir.create("figures", showWarnings = FALSE)

## ---- Route A: quick ----
gA <- build_graph_from_mat(
  mat, method = "WGCNA", transfrom.method = "none", proc = "bonferroni",
  r.threshold = 0.6, p.threshold = 0.05,
  node_annotation = tax, top_modules = 15, seed = 1115
)
ggsave("figures/06-wgcna-routeA.png",
       ggNetView(gA, layout = "stress", fill.by = "Modularity", seed = 1115),
       width = 7, height = 7)

## ---- Route B: full classic WGCNA pipeline ----
WGCNA::disableWGCNAThreads()

expr_mat <- t(mat)                                   # WGCNA wants samples in ROWS
sft   <- WGCNA::pickSoftThreshold(expr_mat, powerVector = c(1:10, seq(12, 30, 2)),
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
                        stringsAsFactors = FALSE)        # EXACTLY columns ID + Module

edge_df <- trans_TOM_in_WGCNA(TOM = TOM, mat = expr_mat, threshold = 0.1)   # or top_k = 20

gB <- build_graph_from_wgcna(
  wgcna_tom = edge_df, module = module_df, node_annotation = tax, seed = 1
)
ggsave("figures/06-wgcna-routeB.png",
       ggNetView(gB, layout = "WGCNA", layout.module = "order",
                 fill.by = "Modularity", inner_shrink = 0.8, seed = 1),
       width = 7, height = 7)

message("OK 06: routeA ", igraph::vcount(gA), " nodes; routeB ",
        igraph::vcount(gB), " nodes / ", igraph::ecount(gB), " edges")
