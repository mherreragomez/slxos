library(slxos)

## --- Columbus: identities and known values ---
data(columbus)
X <- cbind(1, columbus$INC, columbus$HOVAL)
o <- slx_scores(columbus$CRIME, X, columbus_W)
stopifnot(o$id_gap < 1e-8, o$dec_gap < 1e-8)
stopifnot(abs(o$RS_theta - (o$PS + o$OS)) < 1e-8)
stopifnot(abs(o$PS - o$RSstar_rho) < 1e-10)   # PS_theta == RS*_rho
stopifnot(abs(o$PS - 3.736) < 5e-3, abs(o$OS - 2.625) < 5e-3)

## guided test runs and returns a verdict
res <- slx_test(CRIME ~ INC + HOVAL, data = columbus, W = columbus_W)
stopifnot(is.character(res$verdict), res$q == 1L)

## --- Ertur and Koch: reproduces the paper (PS = 15.25, OS = 0.72) ---
data(ertur)
oe <- slx_scores(ertur$lny95, cbind(1, ertur$lns, ertur$lnngd), ertur_W)
stopifnot(oe$id_gap < 1e-8)
stopifnot(abs(oe$PS - 15.25) < 5e-2, abs(oe$OS - 0.72) < 5e-2)

## --- all bundled datasets: identities hold ---
for (nm in c("stlouis", "baltimore", "georgia")) {
  data(list = nm, package = "slxos")
  df <- get(nm); W <- get(paste0(nm, "_W"))
  y <- df[[1]]; X <- cbind(1, as.matrix(df[, -1, drop = FALSE]))
  oo <- slx_scores(y, X, W)
  stopifnot(oo$id_gap < 1e-6, oo$dec_gap < 1e-6)
}

cat("all slxos identity tests passed\n")
