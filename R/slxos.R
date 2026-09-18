# slxos: orthogonal SLX score tests for spatial Durbin models
# Implements the exact decomposition RS_theta = PS_theta + OS_theta of
# Herrera-Gomez (2026). Base R; only 'stats' is imported.
# Calibration under H0:theta=0 is closed-form throughout (a single SARAR fit
# via sarar_mle() feeding the rescaled sandwich in os_rescaled()); no
# resampling / bootstrap procedure is used anywhere in this package.

# ---- internal: coerce/validate a weight matrix -------------------------------
.as_Wmat <- function(W, n, row_standardize = FALSE) {
  if (inherits(W, "listw")) {
    if (!requireNamespace("spdep", quietly = TRUE))
      stop("W is a 'listw'; install 'spdep' or pass a matrix.")
    W <- spdep::listw2mat(W)
  }
  W <- as.matrix(W)
  if (nrow(W) != ncol(W)) stop("W must be square.")
  if (nrow(W) != n) stop("W has ", nrow(W), " rows but the data have ", n, ".")
  rs <- rowSums(W)
  if (row_standardize) {
    if (any(rs == 0)) stop("W has ", sum(rs == 0), " island(s) (zero row sums); cannot row-standardize.")
    W <- W / rs
  } else if (max(abs(rs - 1)) > 1e-8) {
    warning("W is not row-standardized (row sums != 1); the exact identity ",
            "S_rho = S_lambda + bnc'S_theta requires W1 = 1. Pass row_standardize = TRUE.")
  }
  storage.mode(W) <- "double"
  W
}

# ---- internal: real eigenvalues of W (W is symmetric-similar) ----------------
.Wev <- function(W) Re(eigen(W, only.values = TRUE)$values)

# ---- internal: J_theta_theta.1-orthogonal complement of bnc ------------------
# = ordinary orthogonal complement of g = Jtt %*% bnc, via a complete QR.
.ortho <- function(g) qr.Q(qr(matrix(g, ncol = 1)), complete = TRUE)[, -1, drop = FALSE]

#' Exact SLX score decomposition and the classical battery
#'
#' From the OLS fit of \code{y} on \code{X} and a row-standardized weight
#' matrix \code{W}, computes the classical Anselin (1996) battery and the exact
#' decomposition \eqn{RS_\theta = PS_\theta + OS_\theta}, together with the exact
#' \eqn{OF_\theta} and the orientation of the SLX coefficient vector.
#'
#' @param y numeric response, length n.
#' @param X model matrix (n x k) \strong{including} the intercept in column 1.
#' @param W n x n spatial weights (matrix, Matrix, or \code{spdep} listw).
#' @param row_standardize logical; if TRUE, row-standardize W (default FALSE).
#' @return An object of class \code{"slx_scores"}: a list with the scores,
#'   \code{PS} (=RS*_rho), \code{OS}, \code{RS_theta}, \code{OF} and its p-value,
#'   the classical battery, the orientation cosine \code{cosJ}, the condition
#'   number of \eqn{\hat J_{\theta\theta.1}}, and the identity/decomposition gaps.
#' @export
slx_scores <- function(y, X, W, row_standardize = FALSE) {
  y <- as.numeric(y); X <- as.matrix(X); n <- nrow(X); k <- ncol(X); q <- k - 2
  if (k < 2) stop("X must have an intercept and at least one regressor.")
  W <- .as_Wmat(W, n, row_standardize)
  XtX <- crossprod(X); b <- solve(XtX, crossprod(X, y)); e <- as.vector(y - X %*% b)
  s2 <- sum(e^2) / n
  Xnc <- X[, -1, drop = FALSE]; bnc <- b[-1]
  M <- diag(n) - X %*% solve(XtX, t(X)); WX <- W %*% Xnc
  S_theta  <- as.vector(crossprod(WX, e)) / s2
  S_rho    <- as.numeric(crossprod(e, W %*% y)) / s2
  S_lambda <- as.numeric(crossprod(e, W %*% e)) / s2
  Jtt <- crossprod(WX, M %*% WX) / s2
  TW  <- sum(diag(crossprod(W) + W %*% W))
  bJb <- as.numeric(t(bnc) %*% Jtt %*% bnc); D <- bJb + TW
  RS_rho    <- S_rho^2 / D
  RS_lambda <- S_lambda^2 / TW
  PS <- (S_rho - S_lambda)^2 / bJb
  RSstar_lambda <- (S_lambda - (TW / D) * S_rho)^2 / (TW * (1 - TW / D))
  RS_theta <- as.numeric(t(S_theta) %*% solve(Jtt, S_theta))
  if (q >= 1) {
    P <- .ortho(as.vector(Jtt %*% bnc)); PtS <- as.vector(crossprod(P, S_theta))
    C0 <- t(P) %*% crossprod(WX, M %*% WX) %*% P
    OS <- as.numeric(t(PtS) %*% solve(t(P) %*% Jtt %*% P, PtS))
    Z <- WX %*% P; Xa <- cbind(X, Z)
    ea <- as.vector(y - Xa %*% solve(crossprod(Xa), crossprod(Xa, y)))
    dfd <- n - k - q
    OF <- ((sum(e^2) - sum(ea^2)) / q) / (sum(ea^2) / dfd)
    p_OF <- stats::pf(OF, q, dfd, lower.tail = FALSE)
    bslx <- solve(crossprod(cbind(X, WX)), crossprod(cbind(X, WX), y))
    th <- bslx[(k + 1):(2 * k - 1)]
    cosJ <- as.numeric((t(th) %*% Jtt %*% bnc) /
                       sqrt((t(th) %*% Jtt %*% th) * (t(bnc) %*% Jtt %*% bnc)))
  } else {
    P <- NULL; C0 <- NULL; OS <- NA_real_; OF <- NA_real_; p_OF <- NA_real_
    th <- numeric(0); cosJ <- NA_real_
  }
  structure(list(
    n = n, k = k, q = q, coef_names = colnames(X),
    S_rho = S_rho, S_lambda = S_lambda, S_theta = S_theta,
    Jtt = Jtt, TW = TW, bnc = bnc, M = M, WX = WX, P = P, C0 = C0,
    RS_rho = RS_rho,           p_RS_rho = stats::pchisq(RS_rho, 1, lower.tail = FALSE),
    RS_lambda = RS_lambda,     p_RS_lambda = stats::pchisq(RS_lambda, 1, lower.tail = FALSE),
    PS = PS,                   p_PS = stats::pchisq(PS, 1, lower.tail = FALSE),
    RSstar_rho = PS,           p_RSstar_rho = stats::pchisq(PS, 1, lower.tail = FALSE),
    RSstar_lambda = RSstar_lambda, p_RSstar_lambda = stats::pchisq(RSstar_lambda, 1, lower.tail = FALSE),
    RS_theta = RS_theta,       p_RS_theta = stats::pchisq(RS_theta, k - 1, lower.tail = FALSE),
    OS = OS,                   p_OS = if (q >= 1) stats::pchisq(OS, q, lower.tail = FALSE) else NA_real_,
    OF = OF, p_OF = p_OF,
    theta_slx = th, cosJ = cosJ,
    condJ = kappa(Jtt, exact = TRUE),
    id_gap = abs(S_rho - (S_lambda + sum(bnc * S_theta))),
    dec_gap = if (q >= 1) abs(RS_theta - (PS + OS)) else NA_real_
  ), class = "slx_scores")
}

#' SARAR maximum-likelihood fit under H0: theta = 0
#'
#' Concentrated Gaussian log-likelihood of \eqn{y = \rho W y + X\beta + u},
#' \eqn{u = \lambda W u + e}, maximised over \eqn{(\rho,\lambda)}.
#' @inheritParams slx_scores
#' @return list with \code{rho}, \code{lam}, \code{beta}, \code{sigma2}, \code{logLik}.
#' @export
sarar_mle <- function(y, X, W, row_standardize = FALSE) {
  y <- as.numeric(y); X <- as.matrix(X); n <- length(y)
  W <- .as_Wmat(W, n, row_standardize); ev <- .Wev(W); I <- diag(n)
  negll <- function(par) {
    A <- I - par[1] * W; B <- I - par[2] * W
    ys <- B %*% (A %*% y); Xs <- B %*% X
    u <- ys - Xs %*% solve(crossprod(Xs), crossprod(Xs, ys))
    0.5 * n * log(sum(u^2) / n) - sum(log(1 - par[1] * ev)) - sum(log(1 - par[2] * ev))
  }
  op <- stats::optim(c(0, 0), negll, method = "L-BFGS-B",
                     lower = c(-0.98, -0.98), upper = c(0.98, 0.98))
  A <- I - op$par[1] * W; B <- I - op$par[2] * W
  ys <- B %*% (A %*% y); Xs <- B %*% X
  beta <- solve(crossprod(Xs), crossprod(Xs, ys))
  u <- ys - Xs %*% beta
  list(rho = op$par[1], lam = op$par[2], beta = as.vector(beta),
       sigma2 = sum(u^2) / n, logLik = -op$value - 0.5 * n * (log(2 * pi) + 1))
}

#' Error-robust (rescaled sandwich) OS_theta
#'
#' The rescaled sandwich statistic robust to a spatial-error parameter
#' \eqn{\lambda}. If \code{lambda} is NULL it is taken from a SARAR fit under
#' \eqn{H_0:\theta=0} (recommended).
#' @inheritParams slx_scores
#' @param lambda optional error parameter; if NULL, estimated by \code{sarar_mle}.
#' @return list with \code{stat}, \code{df}, \code{p}, \code{lambda}.
#' @export
os_rescaled <- function(y, X, W, lambda = NULL, row_standardize = FALSE) {
  y <- as.numeric(y); X <- as.matrix(X); n <- nrow(X); k <- ncol(X); q <- k - 2
  W <- .as_Wmat(W, n, row_standardize)
  if (is.null(lambda)) lambda <- sarar_mle(y, X, W)$lam
  XtX <- crossprod(X); b <- solve(XtX, crossprod(X, y)); e <- as.vector(y - X %*% b)
  Xnc <- X[, -1, drop = FALSE]; bnc <- b[-1]; M <- diag(n) - X %*% solve(XtX, t(X)); WX <- W %*% Xnc
  Jtt <- crossprod(WX, M %*% WX) / (sum(e^2) / n)
  P <- .ortho(as.vector(Jtt %*% bnc))
  A <- solve(diag(n) - lambda * W); Om <- A %*% t(A)
  sig <- sum(e^2) / sum(diag(M %*% Om))
  a <- as.vector(crossprod(P, crossprod(WX, e)))
  V <- sig * (t(P) %*% t(WX) %*% (M %*% Om %*% M) %*% WX %*% P)
  st <- as.numeric(t(a) %*% solve(V, a))
  list(stat = st, df = q, p = stats::pchisq(st, q, lower.tail = FALSE), lambda = lambda)
}

#' Guided SLX orthogonality test (the applied sequence)
#'
#' Runs the full sequence from a formula: OLS battery, the decomposition
#' \eqn{RS_\theta = PS_\theta + OS_\theta}, and a regime-appropriate calibration
#' of \eqn{OS_\theta}, exactly following the guided sequence of the paper
#' (Section "Reading the classical battery through the decomposition").
#' With \code{calibrate = "auto"}, the robust error test \eqn{RS^*_\lambda} is
#' used as a diagnostic (Step 3): the exact \eqn{OF_\theta} is reported when it
#' is not significant, and the closed-form rescaled-sandwich statistic of
#' Section "A closed-form correction for the lambda distortion" is reported
#' otherwise, from a single SARAR fit under \eqn{H_0:\theta=0} and with no
#' resampling.
#'
#' @param formula a model formula (the intercept is added automatically).
#' @param data a data.frame.
#' @param W n x n spatial weights (matrix, Matrix, or listw).
#' @param calibrate one of "auto","chi2","exact","sandwich".
#' @param row_standardize logical; row-standardize W (default FALSE).
#' @return An object of class \code{"slxos"}.
#' @export
slx_test <- function(formula, data, W,
                     calibrate = c("auto", "chi2", "exact", "sandwich"),
                     row_standardize = FALSE) {
  calibrate <- match.arg(calibrate)
  mf <- stats::model.frame(formula, data)
  y <- stats::model.response(mf)
  X <- stats::model.matrix(attr(mf, "terms"), mf)
  n <- length(y); W <- .as_Wmat(W, n, row_standardize)
  o <- slx_scores(y, X, W)
  out <- list(scores = o, formula = formula, n = o$n, k = o$k, q = o$q,
              calibrate = calibrate)
  if (o$q < 1) {
    out$decisive <- list(method = "none (k=2)", stat = NA, p = NA)
    out$verdict <- "k = 2: OS_theta is undefined; the SLX branch coincides with the classical tests."
    return(structure(out, class = "slxos"))
  }
  fit <- NULL
  method <- calibrate
  if (calibrate == "auto")
    method <- if (o$p_RSstar_lambda > 0.05) "exact" else "sandwich"
  dec <- switch(method,
    chi2     = list(method = "OS_theta (chi-square)", stat = o$OS, p = o$p_OS),
    exact    = list(method = "OF_theta (exact F)",    stat = o$OF, p = o$p_OF),
    sandwich = { fit <- sarar_mle(y, X, W)
                 r <- os_rescaled(y, X, W, lambda = fit$lam)
                 list(method = "rescaled sandwich", stat = r$stat, p = r$p, lambda = r$lambda) })
  out$decisive <- dec
  out$sarar <- if (!is.null(fit)) list(rho = fit$rho, lam = fit$lam) else NULL
  out$verdict <- if (dec$p < 0.05)
    sprintf("OS_theta rejects (%s, p = %.4f): the SLX term carries content orthogonal to the common-factor direction.",
            dec$method, dec$p)
  else
    sprintf("OS_theta does not reject (%s, p = %.4f): the SLX evidence is the common-factor direction the classical battery already carries.",
            dec$method, dec$p)
  structure(out, class = "slxos")
}

# ---- print / summary methods -------------------------------------------------

#' @export
print.slx_scores <- function(x, ...) {
  cat(sprintf("SLX score decomposition (n = %d, k = %d, q = k-2 = %d)\n", x$n, x$k, x$q))
  cat(sprintf("  identity gap = %.1e   decomposition gap = %.1e   cond(Jtt) = %.1f\n",
              x$id_gap, x$dec_gap, x$condJ))
  cat("  classical battery:\n")
  cat(sprintf("    RS_rho=%.3f (p=%.4f)  RS_lambda=%.3f (p=%.4f)\n", x$RS_rho, x$p_RS_rho, x$RS_lambda, x$p_RS_lambda))
  cat(sprintf("    RS*_rho(=PS_theta)=%.3f (p=%.4f)  RS*_lambda=%.3f (p=%.4f)\n",
              x$PS, x$p_PS, x$RSstar_lambda, x$p_RSstar_lambda))
  cat("  SLX decomposition  RS_theta = PS_theta + OS_theta:\n")
  cat(sprintf("    RS_theta=%.3f (p=%.4f, df=%d)\n", x$RS_theta, x$p_RS_theta, x$k - 1))
  cat(sprintf("    PS_theta=%.3f            (common-factor / lag direction)\n", x$PS))
  if (x$q >= 1) {
    cat(sprintf("    OS_theta=%.3f (p=%.4f, df=%d)   <- orthogonal content\n", x$OS, x$p_OS, x$q))
    cat(sprintf("    OF_theta=%.3f (p=%.4f, exact)    cos_J(theta,bnc)=%.3f\n", x$OF, x$p_OF, x$cosJ))
  } else cat("    OS_theta undefined (k = 2).\n")
  invisible(x)
}

#' @export
print.slxos <- function(x, ...) {
  cat("Guided SLX orthogonality test\n")
  cat(sprintf("  n = %d, k = %d, q = %d\n", x$n, x$k, x$q))
  s <- x$scores
  cat(sprintf("  PS_theta = %.3f (p=%.4f) ; RS*_lambda p = %.4f (regime)\n",
              s$PS, s$p_PS, s$p_RSstar_lambda))
  if (x$q >= 1)
    cat(sprintf("  RS_theta = %.3f = PS_theta + OS_theta ; OS_theta = %.3f (chi2 p=%.4f)\n",
                s$RS_theta, s$OS, s$p_OS))
  if (!is.null(x$sarar))
    cat(sprintf("  SARAR fit: rho = %+.3f, lambda = %+.3f\n", x$sarar$rho, x$sarar$lam))
  cat(sprintf("  decisive: %s -> stat = %.3f, p = %.4f\n",
              x$decisive$method, x$decisive$stat, x$decisive$p))
  cat("  ", x$verdict, "\n", sep = "")
  invisible(x)
}

#' @export
summary.slxos <- function(object, ...) { print(object$scores); print(object); invisible(object) }
