\name{spatialKMeans-methods}
\docType{methods}
\alias{spatialKMeans}
\alias{class:SpatialKMeans}
\alias{SpatialKMeans-class}
\alias{spatialKMeans-methods}

\alias{spatialKMeans,SparseImagingExperiment-method}
\alias{summary,SpatialKMeans2-method}

\title{Spatially-aware k-means clustering}
\description{
    Performs spatially-aware (SA) or spatially-aware structurally-adaptive (SASA) clustering of imaging data. The data are first projected into an embedded feature space where spatial structure is maintained using the Fastmap algorithm, and then ordinary k-means clustering is performed on the projected dataset.
}
\usage{
\S4method{spatialKMeans}{SparseImagingExperiment}(x, r = 1, k = 3,
    method = c("gaussian", "adaptive"),
    dist = "chebyshev", tol.dist = 1e-9,
    iter.max = 10, nstart = 10,
    algorithm = c("Hartigan-Wong", "Lloyd", "Forgy", "MacQueen"),
    ncomp = 10, BPPARAM = getCardinalBPPARAM(), \dots)

\S4method{summary}{SpatialKMeans2}(object, \dots)
}
\arguments{
    \item{x}{The imaging dataset to cluster.}
    \item{r}{The spatial neighborhood radius of nearby pixels to consider. This can be a vector of multiple radii values.}
    \item{k}{The number of clusters. This can be a vector to try different numbers of clusters.}
    \item{method}{The method to use to calculate the spatial smoothing kernels for the embedding. The 'gaussian' method refers to spatially-aware (SA) clustering, and 'adaptive' refers to spatially-aware structurally-adaptive (SASA) clustering.}
    \item{dist}{The type of distance metric to use when calculating neighboring pixels based on \code{r}. The options are `radial', `manhattan', `minkowski', and `chebyshev' (the default).}
    \item{tol.dist}{The distance tolerance used for matching pixels when calculating pairwise distances between neighborhoods. This parameter should only matter when the data is not gridded. (Only considers `radial' distance.)}
    \item{iter.max}{The maximum number of k-means iterations.}
    \item{nstart}{The number of restarts for the k-means algorithm.}
    \item{algorithm}{The k-means algorithm to use. See \code{\link{kmeans}} for details.}
    \item{ncomp}{The number of fastmap components to calculate.}
    \item{\dots}{Ignored.}
    \item{object}{A fitted model object to summarize.}
    \item{BPPARAM}{An optional instance of \code{BiocParallelParam}. See documentation for \code{\link{bplapply}}.}
}
\value{
    An object of class \code{SpatialKMeans2}, which is a \code{ImagingResult}, or an object of class \code{SpatialKMeans}, which is a \code{ResultSet}. Each element of the \code{resultData} slot contains at least the following components:

    \describe{
        \item{\code{cluster}:}{A vector of integers indicating the cluster for each pixel in the dataset.}
        \item{\code{centers}:}{A matrix of cluster centers.}
        \item{\code{correlation}:}{A matrix with the feature correlations with each cluster.}
    }
}
\author{
    Kylie A. Bemis
}
\references{
    Alexandrov, T., & Kobarg, J. H. (2011). Efficient spatial segmentation of large imaging mass spectrometry datasets with spatially aware clustering. Bioinformatics, 27(13), i230-i238. doi:10.1093/bioinformatics/btr246

    Faloutsos, C., & Lin, D. (1995). FastMap: A Fast Algorithm for Indexing, Data-Mining and Visualization of Traditional and Multimedia Datasets. Presented at the Proceedings of the 1995 ACM SIGMOD international conference on Management of data.
}
\seealso{
    \code{\link{spatialShrunkenCentroids}}
}
\examples{
setCardinalBPPARAM(SerialParam())

set.seed(1)
x <- simulateImage(preset=3, dim=c(10,10), npeaks=10,
    peakheight=c(4,6,8), representation="centroid")

res <- spatialKMeans(x, r=1, k=4, method="adaptive")

summary(res)

image(res, model=1)
}

\keyword{spatial}
\keyword{clustering}
