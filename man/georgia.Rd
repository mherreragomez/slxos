\name{georgia}
\alias{georgia}
\alias{georgia_W}
\docType{data}
\title{Georgia counties (GWR data)}
\description{159 Georgia counties (Fotheringham et al. GWR data), with the
percentage with a bachelor's degree \code{PctBach} and covariates
\code{PctRural}, \code{PctEld}, \code{PctFB}, \code{PctPov}, \code{PctBlack},
and \code{georgia_W} the row-standardized queen-contiguity weights.}
\usage{data(georgia)}
\format{\code{georgia}: 159 x 6 data.frame; \code{georgia_W}: 159 x 159 weights.}
\source{libpysal example \code{georgia}.}
\examples{
data(georgia)
slx_test(PctBach ~ PctRural + PctEld + PctFB + PctPov + PctBlack,
         data = georgia, W = georgia_W)                       # OS_theta ~ 0
}
\keyword{datasets}
