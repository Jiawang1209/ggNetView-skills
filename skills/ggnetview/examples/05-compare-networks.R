## ggNetView example 5 — compare networks across groups
## ggNetView_multi_link() builds one sub-network per group. NOTE: it has NO `scale`
## argument (that belongs to single-plot ggNetView()); use `scale_groups`.

library(ggNetView)
library(ggplot2)

data("otu_rare_relative"); data("otu_sample")

N_OTU <- 150
keep  <- order(rowSums(otu_rare_relative), decreasing = TRUE)[seq_len(min(N_OTU, nrow(otu_rare_relative)))]
mat   <- as.matrix(otu_rare_relative[keep, , drop = FALSE])

dir.create("figures", showWarnings = FALSE)

## one sub-network per group, laid out side by side with cross-group links
out <- ggNetView_multi_link(
  mat              = mat,
  group_info       = otu_sample,   # data.frame with Sample + Group columns
  transfrom.method = "none",
  r.threshold      = 0.6, p.threshold = 0.05,
  method           = "WGCNA", cor.method = "pearson", proc = "BH",
  module.method    = "Fast_greedy",
  layout           = "gephi", layout.module = "adjacent",
  center           = TRUE, top_modules = 15, shrink = 0.5,
  scale_groups     = FALSE,        # keep each group's native size (NOT "scale")
  jitter           = TRUE, jitter_sd = 0.3, anchor_dist = 30,
  seed             = 1115, orientation = "up", angle = 0
)
ggsave("figures/05-multi-link.png", out$p, width = 9, height = 6)

## circular comparison with explicit brackets.
## group names are case-sensitive; `order` must list ALL groups.
grp <- unique(otu_sample$Group)
out2 <- ggNetView_multi_link(
  mat = mat, group_info = otu_sample,
  method = "WGCNA", cor.method = "pearson", proc = "BH",
  r.threshold = 0.6, p.threshold = 0.05,
  layout = "circular_modules_equal_gephi_layout", layout.module = "order",
  scale_groups = TRUE, dropOthers = TRUE, link_level = "Module&Node2",
  comparisons = TRUE, comparisons_groups = list(grp[1:2]),
  order = grp, seed = 1115
)
ggsave("figures/05-multi-link-circular.png", out2$p, width = 9, height = 7)

message("OK 05: groups = ", paste(grp, collapse = "/"),
        "; per-group info rows = ", nrow(out$info))
