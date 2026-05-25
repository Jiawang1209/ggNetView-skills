## ggNetView example 7 — keystone taxa: Zi-Pi roles + hub nodes
## ggnetview_zipi() takes a NODE TABLE + ADJACENCY MATRIX (not a graph).
## get_node_centrality()/get_node_ivi() RETURN an augmented tbl_graph — assign it.

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

## --- Zi-Pi keystone roles (module hub / connector / network hub / peripheral) ---
nodes_bulk <- get_graph_nodes(graph_obj)        # node table (has Modularity, Degree)
adj_mat    <- get_graph_adjacency(graph_obj)    # square adjacency matrix
zipi <- ggnetview_zipi(
  nodes_bulk, adj_mat,
  modularity_col = "Modularity", degree_col = "Degree",
  zi_threshold = 2.5, pi_threshold = 0.62
)
message("Zi-Pi roles: ", paste(names(table(zipi$data$type)), collapse = ", "))
ggsave("figures/07-zipi.png", zipi$plot, width = 7, height = 6)

## --- hub / influential nodes ---
graph_cent <- get_node_centrality(graph_obj)    # adds Hub_score, Betweenness, PageRank, ...
top_hubs <- graph_cent %>%
  tidygraph::activate("nodes") %>%
  tibble::as_tibble() %>%
  dplyr::arrange(dplyr::desc(Hub_score)) %>%
  utils::head(10)
print(top_hubs[, intersect(c("name", "Hub_score", "Betweenness"), names(top_hubs))])

## get_node_ivi() needs the Suggests-only `influential` package; guard so this still runs
if (requireNamespace("influential", quietly = TRUE)) {
  graph_ivi <- get_node_ivi(graph_obj)          # adds a single integrated IVI column
  message("IVI column added")
} else {
  message("skip IVI: install.packages('influential') to enable get_node_ivi()")
}

message("OK 07: Zi-Pi + hub-node analysis done")
