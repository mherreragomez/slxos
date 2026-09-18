## Reproduces the appendix table "The orthogonal direction in public spatial
## Durbin data" from the datasets bundled in slxos. Run:  Rscript reproduce_appendix.R
library(slxos)

cases <- list(
  ertur     = list(f = lny95  ~ lns + lnngd,                                     W = "ertur_W"),
  stlouis   = list(f = HR8893 ~ RDAC90 + PE87,                                   W = "stlouis_W"),
  columbus  = list(f = CRIME  ~ INC + HOVAL,                                     W = "columbus_W"),
  baltimore = list(f = PRICE  ~ NROOM+NBATH+PATIO+FIREPL+AC+GAR+AGE+LOTSZ+SQFT,  W = "baltimore_W"),
  georgia   = list(f = PctBach~ PctRural+PctEld+PctFB+PctPov+PctBlack,           W = "georgia_W"))

cat(sprintf("%-10s %4s %3s %10s %9s %11s %13s %13s %7s\n",
            "dataset","n","k","PS_theta","OS_theta","OF p","sw.lambda p","(rho,lam)","cosJ"))
cat(strrep("-", 96), "\n")
for (nm in names(cases)) {
  data(list = nm, package = "slxos")
  df <- get(nm); W <- get(cases[[nm]]$W)
  o  <- slx_scores(model.response(model.frame(cases[[nm]]$f, df)),
                   model.matrix(cases[[nm]]$f, df), W)
  if (o$q >= 1) {
    fit <- sarar_mle(model.response(model.frame(cases[[nm]]$f, df)),
                      model.matrix(cases[[nm]]$f, df), W)
    r <- os_rescaled(model.response(model.frame(cases[[nm]]$f, df)),
                     model.matrix(cases[[nm]]$f, df), W, lambda = fit$lam)
    cat(sprintf("%-10s %4d %3d %10.2f %6.2f(%.3f) %9.4f %11.3f  (%+.2f,%+.2f) %6.3f\n",
                nm, o$n, o$k, o$PS, o$OS, o$p_OS, o$p_OF, r$p, fit$rho, fit$lam, o$cosJ))
  } else {
    cat(sprintf("%-10s %4d %3d %10.2f      ---   (OS_theta undefined at k = 2)\n", nm, o$n, o$k, o$PS))
  }
}
