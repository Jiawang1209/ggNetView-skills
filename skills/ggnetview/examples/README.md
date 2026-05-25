# ggNetView examples

Runnable `.R` scripts mirroring the ten workflows in `../workflows.md`. Each uses the
datasets bundled with ggNetView, so they run as-is after `install.packages`-ing the
package and its dependencies.

## Run

```bash
cd skills/ggnetview/examples
# core (01–06)
Rscript 01-build-and-plot.R
Rscript 02-rmt-threshold.R
Rscript 03-topology.R
Rscript 04-layouts.R
Rscript 05-compare-networks.R
Rscript 06-wgcna.R
# advanced (07–10)
Rscript 07-zipi-hub.R            # keystone taxa: Zi-Pi roles + hub / IVI nodes
Rscript 08-mantel-environment.R  # network vs environment: Mantel + correlation heatmap
Rscript 09-multiomics-bipartite.R# two-omics / bipartite network (double_mat)
Rscript 10-subgraph-persample.R  # subgraph by module + per-sample networks & topology
```

Figures are written to `figures/` (git-ignored).

## Demo subset

For a fast demo, every script caps the data to the top `N_OTU` (default 150)
most-abundant OTUs:

```r
N_OTU <- 150   # set to Inf, or delete the subset block, to use the full dataset
```

The full bundled matrix is 2859 OTUs × 18 samples; the full run (especially the RMT
scan and WGCNA TOM) takes minutes. The API calls are identical either way.

## Verified

The **core scripts (01–06)** were run against **ggNetView 0.1.0 on R 4.5.1** (the
demo subset). The function names and arguments match the package exactly — notably
`ggNetView()` (camelCase), `transfrom.method` (source spelling), and `scale_groups`
(not `scale`) for `ggNetView_multi_link()`.

The **advanced scripts (07–10)** were also **run end-to-end on ggNetView 0.1.0 /
R 4.5.1** (demo subset): `07` emits Zi-Pi roles + a hub table + IVI, `08` produces
112 Mantel link rows and the straight/curved figures, `09` builds the 60-node
bipartite network, `10` returns per-sample subgraphs + topology. Two notes:

- `10` calls `droplevels(Modularity)` before `get_subgraph()`. `get_subgraph()` needs
  every `Modularity` level populated; the appended `"Others"` level is empty unless the
  network has more modules than `top_modules`, which isn't the case on this small demo
  subset. On real data with many modules this line is a harmless no-op (see
  `../troubleshooting.md`).
- `08`'s `env_select` indices assume the bundled `Envdf_4st`/`Spedf` shapes, and `09`
  splits one OTU table into two blocks purely for demonstration — adjust to your data.
