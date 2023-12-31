\name{pixelApply-methods}
\docType{methods}

\alias{pixelApply}
\alias{pixelApply-methods}
\alias{pixelApply,SparseImagingExperiment-method}

\alias{featureApply}
\alias{featureApply-methods}
\alias{featureApply,SparseImagingExperiment-method}

\title{Apply functions over imaging datasets}
\description{
	Apply an existing or a user-specified function over either all of the features or all of the pixels of a \code{\linkS4class{SparseImagingExperiment}} or \code{\linkS4class{SImageSet}}. These are provided by analogy to the 'apply' family of functions, but allowing greater efficiency and convenience when applying functions over an imaging dataset.
}
\usage{
\S4method{pixelApply}{SparseImagingExperiment}(.object, .fun, \dots,
    .simplify = TRUE, .outpath = NULL,
    .blocks = getCardinalNumBlocks(), .verbose = getCardinalVerbose(),
    BPPARAM = getCardinalBPPARAM())

\S4method{featureApply}{SparseImagingExperiment}(.object, .fun, \dots,
    .simplify = TRUE, .outpath = NULL,
    .blocks = getCardinalNumBlocks(), .verbose = getCardinalVerbose(),
    BPPARAM = getCardinalBPPARAM())
}
\arguments{
    \item{.object}{An imaging dataset.}
    \item{.fun}{The function to be applied.}
    \item{\dots}{Additional arguments passed to \code{.fun}.}
    \item{.blocks}{If FALSE (the default), each feature-vector or image-vector will be loaded and processed individually. If TRUE, or a positive integer, the data will be split into that many blocks, and the function (specified by \code{.fun}) will be applied to each block. The number of blocks can be specified as a number, or \code{getCardinalNumBlocks()} will be used.}
    \item{.simplify}{If applying over blocks, then a function to be used to simplify the list of results. Otherwise, a logical value giving whether the results should be simplified into a matrix or array rather than a list.}
    \item{.outpath}{The path to a file where the output data will be written. Results will be kept in-memory if this is NULL. Results will be coerced to a numeric vector before being written to file.}
    \item{.verbose}{Should progress messages be printed?}
    \item{BPPARAM}{An optional instance of \code{BiocParallelParam}. See documentation for \code{\link{bplapply}}.}
}
\details{

    #### For \code{\linkS4class{SparseImagingExperiment}}-derived classes ####

    For \code{pixelApply}, the function is applied to the feature vector(s) belonging to pixel(s).

    For \code{featureApply}, the function is applied to the vector(s) of intensity values (i.e., the flattened image) corresponding to the feature(s).

    For \code{spatialApply}, the function is applied to neighborhoods of feature-vectors corresponding to neighboring pixels. The maximum distance in each dimension for a pixel to be considered a neighbor is given by \code{.r}. The first argument to \code{.fun} is a matrix of column-vectors.

    If \code{.blocks} is provided (either TRUE or a positive integer), then the data is split into blocks beforehand, and entire blocks are loaded and passed to the function as a matrix of column-vectors. Otherwise, single vectors are passed to the function individually. If blocks are used, then \code{.simplify} should be a function that simplifies a \code{list} of results.

    Note that for \code{spatialApply} (only), if blocks are used, the result is NOT guaranteed to be in the correct order; instead the result will have a \code{attr(ans, "idx")} attribute giving the proper order (pixel IDs) of the results, and the \code{.simplify} function should likely re-order the results.

    The following attributes are assigned to the object passed to \code{.fun}, accessible via \code{attr()}:

    \itemize{
        \item{\code{idx}: The indices of the current pixel(s) or feature(s).}
        \item{\code{mcols}: Either \code{featureData(.object)} for \code{pixelApply} or \code{pixelData(.object)} for \code{featureApply}.}
    }

    Additionally, the following attributes are made available during a call to \code{spatialyApply()}:

    \itemize{
        \item{\code{centers}: A vector indicating which column(s) should be considered the center(s) of the neighborhood(s).}
        \item{\code{neighbors}: A list of vectors indicating which column(s) should be considered the neighborhoods. Only relevant if using \code{.blocks}.}
        \item{\code{offsets}: A matrix where the rows are the spatial offsets of the pixels in the neighborhood(s) from the center pixel(s).}
    }

    Additionally, any named components of \code{.params} will also be provided as attributes, subsetted to the current element.

    #### For \code{\linkS4class{SImageSet}}-derived classes ####

    The use of \code{.pixel} and \code{.feature} can be used to apply the function over only a subset of pixels or features (or both), allowing faster computation when calculation on only a subset of data is needed.

    For \code{pixelApply}, the function is applied to the feature vector belonging to each pixel. The use of \code{.feature.groups} allows code{\link{tapply}}-like functionality on the feature vectors, applied separately to each pixel.

    For \code{featureApply}, the function is applied to the vector of intensity values (i.e., the flattened image) corresponding to each feature. The use of \code{.feature.groups} allows code{\link{tapply}}-like functionality on the flattened image intensity vectors, applied separately to each feature.

    The \code{fData} from \code{.object} is installed into the environment of \code{.fun} for \code{pixelApply}, and the \code{pData} from \code{.object} is installed into the environment of \code{.fun} for \code{featureApply}. This allows access to the symbols from \code{fData} or \code{pData} during the execution of \code{.fun}. If \code{.fun} already has an environment, it is retained as the parent of the installed environment.

    Additionally, the following objects are made available by installing them into the \code{.fun} environment:

    \itemize{
        \item{\code{.Object}: The passed \code{.object}. (Note the case.)}
        \item{\code{.Index}: The index of the current iteration.}
    }
}
\value{
    If \code{.simplify = FALSE}, a list. Otherwise, a vector or matrix, or a higher-dimensional array if grouping is specified, or the output of the provided \code{.simplify} function.
}
\author{
	Kylie A. Bemis
}
\seealso{
    \code{\linkS4class{MSImagingExperiment}},
    \code{\linkS4class{MSImageSet}}
}
\examples{
setCardinalBPPARAM(SerialParam())

set.seed(2)
data <- simulateImage(preset=1, npeaks=10, dim=c(10,10))

# calculate TIC for each pixel
tic <- pixelApply(data, sum)

# calculate mean spectrum
ms <- featureApply(data, mean)
}
\keyword{manip}

