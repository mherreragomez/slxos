\name{slx_test}
\alias{slx_test}
\alias{print.slxos}
\alias{summary.slxos}
\title{Guided SLX orthogonality test (the applied sequence)}
\description{Runs the full diagnostic sequence from a formula: the OLS battery,
the decomposition \eqn{RS_\theta = PS_\theta + OS_\theta}, and a regime-appropriate
calibration of \eqn{OS_\theta}, following the guided sequence of the paper. With
\code{calibrate = "auto"}, \eqn{RS^*_\lambda} is used as a diagnostic: the exact
\eqn{OF_\theta} is reported when it is not significant, and the closed-form
rescaled-sandwich statistic (a single SARAR fit under \eqn{H_0:\theta=0}, no
resampling) is reported otherwise.}
\usage{slx_test(formula, data, W, calibrate = c("auto", "chi2", "exact",
    "sandwich"), row_standardize = FALSE)}
\arguments{
\item{formula}{a model formula; the intercept is added automatically.}
\item{data}{a data.frame.}
\item{W}{\code{n} x \code{n} spatial weights (matrix, Matrix, or listw).}
\item{calibrate}{one of "auto","chi2","exact","sandwich".}
\item{row_standardize}{logical; row-standardize \code{W}. Default FALSE.}
}
\value{An object of class \code{"slxos"} with the \code{scores}, the \code{decisive}
test, the SARAR fit (when computed), and a plain-language \code{verdict}.}
\examples{
data(columbus)
slx_test(CRIME ~ INC + HOVAL, data = columbus, W = columbus_W)
}
