\name{columbus}
\alias{columbus}
\alias{columbus_W}
\docType{data}
\title{Columbus (OH) neighbourhood crime}
\description{The 49-neighbourhood Columbus crime data of Anselin (1988), with
\code{CRIME} (residential burglaries and vehicle thefts per 1000 households),
\code{INC} (household income) and \code{HOVAL} (housing value), together with the
row-standardized first-order (rook) contiguity matrix \code{columbus_W}. Extracted
verbatim from the \pkg{libpysal} example collection; the same data ship in
\pkg{spData}/\pkg{spdep}.}
\usage{data(columbus)}
\format{\code{columbus}: a data.frame with 49 rows and columns CRIME, INC, HOVAL.
\code{columbus_W}: a 49 x 49 row-standardized weight matrix.}
\source{Anselin, L. (1988). Spatial Econometrics: Methods and Models.}
\keyword{datasets}
