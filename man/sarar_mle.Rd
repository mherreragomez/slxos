\name{sarar_mle}
\alias{sarar_mle}
\title{SARAR maximum-likelihood fit under H0: theta = 0}
\description{Concentrated Gaussian ML of \eqn{y = \rho W y + X\beta + u},
\eqn{u = \lambda W u + e}, maximised over \eqn{(\rho,\lambda)}. Used to obtain
\eqn{\hat\lambda} for the closed-form rescaling in \code{\link{os_rescaled}}.}
\usage{sarar_mle(y, X, W, row_standardize = FALSE)}
\arguments{
\item{y}{numeric response.}
\item{X}{model matrix including the intercept.}
\item{W}{spatial weights (matrix, Matrix, or listw).}
\item{row_standardize}{logical; row-standardize \code{W}. Default FALSE.}
}
\value{A list with \code{rho}, \code{lam}, \code{beta}, \code{sigma2}, \code{logLik}.}
\examples{
data(columbus)
sarar_mle(columbus$CRIME, cbind(1, columbus$INC, columbus$HOVAL), columbus_W)
}
