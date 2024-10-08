\name{SpatialNMF}

\alias{SpatialNMF}
\alias{class:SpatialNMF}
\alias{SpatialNMF-class}

\alias{NMF}
\alias{NMF,ANY-method}
\alias{NMF,SpectralImagingExperiment-method}
\alias{predict,SpatialNMF-method}
\alias{plot,SpatialNMF,missing-method}
\alias{image,SpatialNMF-method}

\title{Non-negative matrix factorization}

\description{
	Compute nonnegative matrix factorization using alternating least squares or multiplicative updates.
}

\usage{
\S4method{NMF}{ANY}(x, ncomp = 3, method = c("als", "mult"),
    verbose = getCardinalVerbose(), \dots)

\S4method{NMF}{SpectralImagingExperiment}(x, ncomp = 3, method = c("als", "mult"), \dots)

\S4method{predict}{SpatialNMF}(object, newdata, \dots)

\S4method{plot}{SpatialNMF,missing}(x, type = c("activation", "x"), \dots, xlab, ylab)

\S4method{image}{SpatialNMF}(x, type = "x", \dots)
}
\arguments{
    \item{x}{A dataset in P x N matrix format.}

    \item{ncomp}{The number of components to calculate.}

    \item{method}{The method to use. Alternating least squares ("als") tends to be faster and potentially more accurate, but can be numerically unstable for data with high correlated features. Multiplicative updates ("mult") can be slower, but is more numerically stable.}

    \item{verbose}{Should progress messages be printed?}

    \item{\dots}{Options passed to \code{\link[irlba]{irlba}}.}

    \item{object}{A \code{SpatialNMF} object.}

    \item{newdata}{A new \code{SpectralImagingExperiment} for which to calculate the scores.}

    \item{type}{The type of plot to display.}

    \item{xlab, ylab}{Plotting labels.}
}

\value{
   An object of class \code{SpatialNMF} derived from \code{SpatialResults}, containing the fitted \code{\link[matter]{nnmf}} object and the spatial metadata.
}

\author{
	Kylie A. Bemis
}

\seealso{
    \code{\link[matter]{nnmf_als}},
    \code{\link[matter]{nnmf_mult}},
    \code{\link{PCA}},
    \code{\link{spatialFastmap}}
}

\examples{
set.seed(1, kind="L'Ecuyer-CMRG")
mse <- simulateImage(preset=2, npeaks=20, dim=c(10,10),
    centroided=TRUE)

# project to principal components
mf <- NMF(mse, ncomp=2)

# visualize first 2 components
image(mf, superpose=FALSE, scale=TRUE)
}

\keyword{multivariate}

