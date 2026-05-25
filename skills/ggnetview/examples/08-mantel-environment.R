## ggNetView example 8 — network vs environment: Mantel test + correlation heatmap
## gglink_heatmaps() returns a LIST of 3: [[1]] straight links, [[2]] curved links,
## [[3]] the stats data.frame. `env`/`spec` are samples x variables, same row order.

library(ggNetView)
library(ggplot2)

data("Envdf_4st")   # environmental table: rows = samples, cols = env factors
data("Spedf")       # species table:       rows = samples (same order!), cols = species

dir.create("figures", showWarnings = FALSE)

## Mantel branch: each spec block (a whole community) vs each env column.
out <- gglink_heatmaps(
  env  = Envdf_4st,
  spec = Spedf,
  env_select  = list(Env01 = 1:14, Env02 = 15:28,    # one heatmap quadrant per block;
                     Env03 = 29:42, Env04 = 43:56),  #   length MUST equal length(orientation)
  spec_select = list(Spec01 = 1:15, Spec02 = 16:30), # one central network per block
  relation_method  = "mantel",        # vs "correlation"
  mantel_kind      = "block_vs_col",  # ecological standard (community vs each env gradient)
  spec_dist_method = "bray",
  env_dist_method  = "euclidean",
  spec_collapse    = TRUE,            # render each spec block as one labelled point
  drop_nonsig      = TRUE,            # hide non-significant links (still kept in stats)
  link_color_by    = "Correlation",   # expression string; SigLineMid -> diverging palette
  SigLineMid       = "white",
  orientation      = c("top_right", "bottom_right", "top_left", "bottom_left")
)

ggsave("figures/08-mantel-straight.png", out[[1]], width = 8, height = 8)
ggsave("figures/08-mantel-curved.png",   out[[2]], width = 8, height = 8)
message("Mantel stats rows: ", nrow(out[[3]]),
        " | columns: ", paste(names(out[[3]]), collapse = ", "))

## raw Mantel numbers without the figure (whole community vs each env column)
mt <- mantel_block_vs_col(
  spec_df = Spedf, env_df = Envdf_4st,
  spec_dist_method = "bray", env_dist_method = "euclidean", permutations = 999
)
print(head(mt))   # ID, Type, Correlation (Mantel r), Pvalue

message("OK 08: Mantel + heatmap figure written")
