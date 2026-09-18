\name{os_rescaled}
\alias{os_rescaled}
\title{Error-robust (rescaled sandwich) OS_theta}
\description{The rescaled sandwich statistic robust to a spatial-error parameter
\eqn{\lambda}. If \code{lambda} is NULL it is taken from a SARAR fit under
\eqn{H_0:\theta=0} (recommended, since an SEM-only estimate conflates the lag).}
\usage{os_rescaled(y, X, W, lambda = NULL, row_standardize = FALSE)}
\arguments{
\item{y}{numeric response.}
\item{X}{model matrix including the intercept.}
\item{W}{spatial weights.}
\item{lambda}{optional error parameter; if NULL, estimated by \code{\link{sarar_mle}}.}
\item{row_standardize}{logical; row-standardize \code{W}. Default FALSE.}
}
\value{A list with \code{stat}, \code{df}, \code{p}, \code{lambda}.}
\examples{
data(columbus)
os_rescaled(columbus$CRIME, cbind(1, columbus$INC, columbus$HOVAL), columbus_W)
}
