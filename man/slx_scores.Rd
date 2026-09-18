\name{slx_scores}
\alias{slx_scores}
\alias{print.slx_scores}
\title{Exact SLX score decomposition and the classical battery}
\description{From the OLS fit of \code{y} on \code{X} and a row-standardized
weight matrix \code{W}, computes the classical Anselin (1996) battery and the
exact decomposition \eqn{RS_\theta = PS_\theta + OS_\theta}, the exact
\eqn{OF_\theta}, and the orientation of the SLX coefficient vector.}
\usage{slx_scores(y, X, W, row_standardize = FALSE)}
\arguments{
\item{y}{numeric response of length \code{n}.}
\item{X}{model matrix (\code{n} x \code{k}) including the intercept in column 1.}
\item{W}{\code{n} x \code{n} spatial weights: a matrix, Matrix, or \pkg{spdep} \code{listw}.}
\item{row_standardize}{logical; if TRUE, row-standardize \code{W}. Default FALSE.}
}
\value{An object of class \code{"slx_scores"} with the scores, \code{PS} (=RS*_rho),
\code{OS}, \code{RS_theta}, \code{OF} and its p-value, the classical battery, the
orientation cosine \code{cosJ}, \code{condJ}, and the identity/decomposition gaps.}
\examples{
data(columbus)
X <- cbind(1, columbus$INC, columbus$HOVAL)
slx_scores(columbus$CRIME, X, columbus_W)
}
