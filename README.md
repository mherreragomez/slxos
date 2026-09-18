# slxos

Orthogonal SLX score tests for spatial Durbin models (Herrera-Gómez, 2026).

The SLX score test decomposes exactly, in every sample, as

```
RS_theta = PS_theta + OS_theta
```

where `PS_theta` is the projection onto the common-factor direction — numerically
the classical robust lag test `RS*_rho` of Anselin (1996) — and `OS_theta` is the
orthogonal remainder that isolates covariate-specific spillovers (the part the
classical battery cannot see). Everything is computed from one OLS fit and a
row-standardized weight matrix `W`.

## Install

```r
# from a local source tarball
install.packages("slxos_0.1.0.tar.gz", repos = NULL, type = "source")
```

Base R only (`Imports: stats`). `spdep`/`spData` are optional (Suggests): if you
pass a `listw`, `spdep` is used to coerce it.

## Quick start

```r
library(slxos)
data(columbus)                                   # Anselin (1988), 49 neighbourhoods

## guided sequence from a formula (chooses OF_theta vs the closed-form
## rescaled sandwich by regime, exactly as in the paper's guided sequence)
slx_test(CRIME ~ INC + HOVAL, data = columbus, W = columbus_W)

## the full battery and decomposition
X <- cbind(1, columbus$INC, columbus$HOVAL)
slx_scores(columbus$CRIME, X, columbus_W)
```

`slx_test()` prints the decomposition, the SARAR regime `(rho, lambda)` when
the rescaled sandwich is used, the decisive test, and a one-line verdict.

## Functions

- `slx_test(formula, data, W, calibrate = "auto", ...)` — the applied sequence.
- `slx_scores(y, X, W)` — classical battery + `RS_theta = PS_theta + OS_theta`,
  exact `OF_theta`, orientation cosine, identity/decomposition gaps.
- `sarar_mle(y, X, W)` — SARAR ML under `H0: theta = 0`.
- `os_rescaled(y, X, W, lambda)` — closed-form error-robust rescaled sandwich,
  a single SARAR fit and no resampling (feed it the SARAR `lambda`; `NULL`
  estimates it via `sarar_mle`).

## Bundled datasets

Five ready-to-use cross-sections, each as a data.frame plus its row-standardized
weight matrix `<name>_W`: `columbus` (Anselin 1988 crime), `stlouis` (homicide),
`baltimore` (house prices), `georgia` (GWR data), and `ertur` (Ertur & Koch 2007
growth, with `ertur_W` the inverse-squared great-circle `W1`). The script
`system.file("examples/reproduce_appendix.R", package = "slxos")` reproduces the
appendix table across all five:

```r
source(system.file("examples/reproduce_appendix.R", package = "slxos"))
```

`ertur` gives `OS_theta` ~ 0 (aligned, like the paper); `stlouis` and `baltimore`
reject; `columbus` and `georgia` do not.

## Weight matrices

Pass a dense matrix, a `Matrix`, or a `spdep` `listw`. The exact identity requires
`W` row-standardized (`W %*% 1 = 1`); set `row_standardize = TRUE` to standardize,
or pass an already-standardized `W`. Islands (zero row sums) are rejected.

## Notes

- `OS_theta` is a `chi^2_{k-2}` score test; `OF_theta` is its exact-F counterpart
  under normality; both are undefined at `k = 2`.
- Under spatial-error contamination `OS_theta` over-rejects; use `calibrate =
  "sandwich"`, which the `"auto"` rule also selects when `RS*_lambda` is
  significant. The rescaling must take `lambda` from the SARAR fit, not an
  SEM-only fit, which conflates the lag. No resampling is used anywhere in
  the package, matching the paper's closed-form correction.
