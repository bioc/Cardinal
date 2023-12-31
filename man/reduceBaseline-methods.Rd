\name{reduceBaseline-methods}
\docType{methods}

\alias{reduceBaseline}
\alias{reduceBaseline-methods}
\alias{reduceBaseline,SparseImagingExperiment-method}

\alias{reduceBaseline.median}
\alias{reduceBaseline.locmin}

\title{Reduce the baseline for an imaging dataset}
\description{
	Apply baseline reduction to the feature vectors of an imaging dataset.
}
\usage{
\S4method{reduceBaseline}{SparseImagingExperiment}(object, method = c("locmin", "median"), \dots)

## Local minima baseline reduction
reduceBaseline.locmin(x, window=5, \dots)

## Interpolated median baseline reduction
reduceBaseline.median(x, blocks=500, fun=median, spar=1, \dots)
}
\arguments{
    \item{object}{An imaging dataset.}
    \item{method}{The baseline reduction method to use.}
    \item{\dots}{Additional arguments passed to the baseline reduction method.}
    \item{x}{The signal to be baseline-corrected.}
    \item{blocks}{The number of intervals to break the mass spectrum into in order to choose minima or medians from which to interpolate the baseline.}
    \item{fun}{Function used to determine the points from which the baseline will be interpolated.}
    \item{spar}{Smoothing parameter for the spline smoothing applied to the spectrum in order to decide the cutoffs for throwing away baseline references that might occur inside peaks.}
    \item{window}{The sliding window (number of data points) to consider when determining the local minima.}
}
\details{
    Baseline reduction is usually performed using the provided functions, but a user-created function can also be passed to \code{method}. In this case it should take the following arguments:

    \itemize{
        \item{\code{x}: A \code{numeric} vector of intensities.}
        \item{\code{\dots}: Additional arguments.}
    }

    A user-created function should return a \code{numeric} vector of the same length. with the baseline-subtracted intensities.

    Internally, \code{\link{pixelApply}} is used to apply the baseline reduction. See its documentation page for more details on additional objects available to the environment installed to the baseline reduction function.
}
\value{
    An object of the same class with the baseline-subtracted spectra.
}
\author{
	Kylie A. Bemis
}
\seealso{
    \code{\linkS4class{MSImagingExperiment}},
    \code{\link{pixelApply}},
    \code{\link{process}}
}
\examples{
setCardinalBPPARAM(SerialParam())

set.seed(2)
data <- simulateImage(preset=1, npeaks=10, dim=c(3,3), baseline=1)
data <- data[,pData(data)$circle]

# queue baseline reduction
data <- reduceBaseline(data, method="median", blocks=100)

# apply baseline reduction
data_nobaseline <- process(data, plot=interactive())
}
\keyword{methods}
