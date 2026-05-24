# ggNetView examples

Runnable `.R` scripts mirroring the six workflows in `../workflows.md`. Each uses the
datasets bundled with ggNetView, so they run as-is after `install.packages`-ing the
package and its dependencies.

## Run

```bash
cd skills/ggnetview/examples
Rscript 01-build-and-plot.R
Rscript 02-rmt-threshold.R
Rscript 03-topology.R
Rscript 04-layouts.R
Rscript 05-compare-networks.R
Rscript 06-wgcna.R
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

These scripts were run against **ggNetView 0.1.0 on R 4.5.1** (the demo subset). The
function names and arguments match the package exactly — notably `ggNetView()`
(camelCase), `transfrom.method` (source spelling), and `scale_groups` (not `scale`)
for `ggNetView_multi_link()`.
