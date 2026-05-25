## ggNetView example 10 — subgraphs: by module and per sample
## get_subgraph() / get_sample_subgraph() return LISTS; the graph is $sub_graph_select.

library(ggNetView)
library(ggplot2)

data("otu_rare_relative"); data("tax_tab")

N_OTU <- 150
keep  <- order(rowSums(otu_rare_relative), decreasing = TRUE)[seq_len(min(N_OTU, nrow(otu_rare_relative)))]
mat   <- otu_rare_relative[keep, , drop = FALSE]
tax   <- tax_tab[match(rownames(mat), tax_tab$OTUID), , drop = FALSE]

dir.create("figures", showWarnings = FALSE)

graph_obj <- build_graph_from_mat(
  mat, transfrom.method = "none", method = "WGCNA", cor.method = "pearson",
  proc = "bonferroni", r.threshold = 0.6, p.threshold = 0.05,
  module.method = "Fast_greedy", node_annotation = tax, top_modules = 15, seed = 1115
)

## (a) subgraph by module — select_module is a character vector of module names
## get_subgraph() needs every Modularity level populated. The builders append an
## "Others" level that is empty unless the network has MORE modules than top_modules.
## This demo subset has <= top_modules modules, so drop the empty level first
## (harmless when there is nothing to drop):
graph_obj <- graph_obj %>%
  tidygraph::activate("nodes") %>%
  tidygraph::mutate(Modularity = droplevels(Modularity))

mods <- levels(get_graph_nodes(graph_obj)$Modularity)             # populated module names
sel  <- head(mods, 3)
sub  <- get_subgraph(graph_obj, select_module = sel)
print(sub$stat_module)                                             # Module, Number
ggsave("figures/10-subgraph-modules.png",
       ggNetView(sub$sub_graph_select, layout = "stress",
                 fill.by = "Modularity", seed = 1115),
       width = 7, height = 7)

## (b) per-sample subgraphs — present = mat[OTU, sample] > min_abundance
res <- get_sample_subgraph(
  graph_obj     = graph_obj,
  mat           = mat,
  min_abundance = 0,                               # 0 for counts; ~0.001 for relative abundance
  select_sample = colnames(mat)[1:3],
  combine       = "union"                          # "intersect" = core OTUs across all selected
)
print(head(res$stat_sample))                       # Sample, Node, Edge, Status
message("per-sample subgraphs: ", length(res$sub_graph_all))

## (c) topology per sample (re-runs get_network_topology() per sample; pass same args + mat)
st <- get_sample_subgraph_topology(
  graph_obj = graph_obj, mat = mat,
  transfrom.method = "none", method = "WGCNA", proc = "bonferroni",
  r.threshold = 0.6, p.threshold = 0.05, bootstrap = 20
)
message("OK 10: per-sample topology rows = ", nrow(st$topology))
