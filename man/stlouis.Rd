\name{stlouis}
\alias{stlouis}
\alias{stlouis_W}
\docType{data}
\title{St. Louis region homicide}
\description{Homicide rates for 78 counties around St. Louis (Messner et al.),
with \code{HR8893} the 1988-1993 homicide rate, \code{RDAC90} resource
deprivation and \code{PE87} police expenditure, and \code{stlouis_W} the
row-standardized first-order (rook) contiguity matrix. Extracted from the
\pkg{libpysal} example set; also in \pkg{spData}/\pkg{spdep}.}
\usage{data(stlouis)}
\format{\code{stlouis}: 78 x 3 data.frame (HR8893, RDAC90, PE87);
\code{stlouis_W}: 78 x 78 row-standardized weights.}
\source{libpysal example \code{stl_hom}.}
\examples{
data(stlouis)
slx_test(HR8893 ~ RDAC90 + PE87, data = stlouis, W = stlouis_W)  # OS_theta rejects
}
\keyword{datasets}
