\name{slxos-package}
\alias{slxos-package}
\alias{slxos}
\docType{package}
\title{Orthogonal SLX Score Tests for Spatial Durbin Models}
\description{
Exact decomposition of the SLX score test, \eqn{RS_\theta = PS_\theta + OS_\theta}:
a projection \eqn{PS_\theta} onto the common-factor direction, numerically equal
to the classical robust lag test \eqn{RS^*_\rho} of Anselin (1996), and an
orthogonal remainder \eqn{OS_\theta} that isolates covariate-specific spillovers.
Everything is computed from a single OLS fit and a row-standardized weight matrix.
}
\details{
Main entry points: \code{\link{slx_test}} (guided sequence from a formula),
\code{\link{slx_scores}} (the full battery and decomposition), and
\code{\link{sarar_mle}} together with \code{\link{os_rescaled}} (the
closed-form, single-fit calibration robust to spatial-error contamination).
}
\references{Herrera-Gomez, M. (2026). Separating Common-Factor from
Covariate-Specific Spillovers: An Exact SLX Score-Test Decomposition.
Working paper.}
\author{Marcos Herrera-Gomez}
