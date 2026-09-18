\name{ertur}
\alias{ertur}
\alias{ertur_W}
\docType{data}
\title{Ertur and Koch (2007) cross-country growth data}
\description{The 91-country cross-section of Ertur and Koch (2007), with the
log of per-capita income in 1995 (\code{lny95}), the log savings rate
(\code{lns}) and \code{lnngd} = \eqn{\log(n+g+\delta)}, plus capital coordinates
and other columns. \code{ertur_W} is the row-standardized inverse-squared
great-circle distance matrix (their \eqn{W_1}). The unrestricted baseline of the
paper is \code{lny95 ~ lns + lnngd} (k = 3); the Solow constraint uses the single
regressor \code{lns - lnngd} (k = 2), where the orthogonal test does not exist.}
\usage{data(ertur)}
\format{\code{ertur}: a data.frame with 91 rows and columns \code{xlong},
\code{ylat}, \code{lny60}, \code{lny95}, \code{gy}, \code{lns}, \code{lnngd}.
\code{ertur_W}: a 91 x 91 row-standardized weight matrix (\eqn{W_1}).}
\source{Ertur, C. and Koch, W. (2007). Growth, technological interdependence and
spatial externalities. Journal of Applied Econometrics 22(6), 1033-1062.}
\examples{
data(ertur)
slx_test(lny95 ~ lns + lnngd, data = ertur, W = ertur_W)   # OS_theta ~ 0 (aligned)
}
\keyword{datasets}
