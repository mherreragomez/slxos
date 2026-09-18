\name{baltimore}
\alias{baltimore}
\alias{baltimore_W}
\docType{data}
\title{Baltimore house sales (Dubin 1992)}
\description{211 house sales in Baltimore, 1978, with \code{PRICE} and hedonic
covariates (\code{NROOM}, \code{NBATH}, \code{PATIO}, \code{FIREPL}, \code{AC},
\code{GAR}, \code{AGE}, \code{LOTSZ}, \code{SQFT}), and \code{baltimore_W} the
row-standardized queen-contiguity weights. Extracted from the \pkg{libpysal}
example set; also in \pkg{spData}/\pkg{spdep}.}
\usage{data(baltimore)}
\format{\code{baltimore}: 211 x 10 data.frame (PRICE + 9 hedonics);
\code{baltimore_W}: 211 x 211 row-standardized weights.}
\source{Dubin, R. (1992). Regional Science and Urban Economics 22, 433-452.}
\examples{
data(baltimore)
slx_test(PRICE ~ NROOM + NBATH + PATIO + FIREPL + AC + GAR + AGE + LOTSZ + SQFT,
         data = baltimore, W = baltimore_W)
}
\keyword{datasets}
