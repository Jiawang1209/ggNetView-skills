## ggNetView example 3 — network topology metrics
## get_network_topology() returns a LIST ($topology, $Robustness). Pass `mat` to
## unlock cohesion / robustness / stability (otherwise they are NA).

library(ggNetView)

data("otu_rare_relative"); data("tax_tab")

N_OTU <- 150
keep  <- order(rowSums(otu_rare_relative), decreasing = TRUE)[seq_len(min(N_OTU, nrow(otu_rare_relative)))]
mat   <- otu_rare_relative[keep, , drop = FALSE]
tax   <- tax_tab[match(rownames(mat), tax_tab$OTUID), , drop = FALSE]

graph_obj <- build_graph_from_mat(
  mat, transfrom.method = "none", method = "WGCNA", proc = "bonferroni",
  r.threshold = 0.6, p.threshold = 0.05,
  node_annotation = tax, top_modules = 15, seed = 1115
)

topo <- get_network_topology(
  graph_obj = graph_obj,
  mat       = mat,                 # required for cohesion / robustness / stability
  transfrom.method = "none", method = "WGCNA", proc = "bonferroni",
  r.threshold = 0.6, p.threshold = 0.05, bootstrap = 20
)

message("topology result is a list: ", paste(names(topo), collapse = ", "))
print(t(topo$topology))            # network-level metrics

## per-node centralities — returns the augmented tbl_graph (assign it)
graph_aug <- get_node_centrality(graph_obj, measures = "all")
message("OK 03: centrality columns added -> ",
        paste(setdiff(names(as.data.frame(tidygraph::activate(graph_aug, "nodes"))),
                      c("name")), collapse = ", "))
