\name{image-methods}
\docType{methods}

\alias{image}
\alias{image-methods}

\alias{image,formula-method}

\alias{image,PositionDataFrame-method}
\alias{image,SparseImagingExperiment-method}
\alias{image,MSImagingExperiment-method}
\alias{image,SparseImagingSummary-method}
\alias{image,MSImagingSummary-method}
\alias{image,SparseImagingResult-method}
\alias{image,PCA2-method}
\alias{image,PLS2-method}
\alias{image,SpatialFastmap2-method}
\alias{image,SpatialKMeans2-method}
\alias{image,SpatialShrunkenCentroids2-method}
\alias{image,SpatialDGMM-method}
\alias{image,MeansTest-method}
\alias{image,SegmentationTest-method}

\alias{image,AnnotatedImage-method}
\alias{image,AnnotatedImageList-method}
\alias{image,AnnotatedImagingExperiment-method}

\alias{image3D}

\alias{image3D,SparseImagingExperiment-method}
\alias{image3D,PCA2-method}
\alias{image3D,PLS2-method}
\alias{image3D,SpatialFastmap2-method}
\alias{image3D,SpatialKMeans2-method}
\alias{image3D,SpatialShrunkenCentroids2-method}
\alias{image3D,SpatialDGMM-method}
\alias{image3D,MeansTest-method}
\alias{image3D,SegmentationTest-method}

\title{Plot an image of the pixel data of an imaging dataset}

\description{
    Create and display images for the pixel data of an imaging dataset using a formula interface.
}

\usage{
\S4method{image}{formula}(x, data = environment(x), \dots,
    xlab, ylab, zlab, subset)

\S4method{image}{PositionDataFrame}(x, formula,
        groups = NULL,
        superpose = FALSE,
        strip = TRUE,
        key = superpose || !is.null(groups),
        normalize.image = c("none", "linear"),
        contrast.enhance = c("none", "suppression", "histogram"),
        smooth.image = c("none", "gaussian", "adaptive"),
        \dots,
        xlab, xlim,
        ylab, ylim,
        zlab, zlim,
        asp = 1,
        layout,
        col = discrete.colors,
        colorscale = viridis,
        colorkey = !key,
        alpha.power = 1,
        subset = TRUE,
        add = FALSE)

\S4method{image}{SparseImagingExperiment}(x, formula,
        feature,
        feature.groups,
        groups = NULL,
        superpose = FALSE,
        strip = TRUE,
        key = superpose || !is.null(groups),
        fun = mean,
        normalize.image = c("none", "linear"),
        contrast.enhance = c("none", "suppression", "histogram"),
        smooth.image = c("none", "gaussian", "adaptive"),
        \dots,
        xlab, xlim,
        ylab, ylim,
        zlab, zlim,
        asp = 1,
        layout,
        col = discrete.colors,
        colorscale = viridis,
        colorkey = !key,
        alpha.power = 1,
        subset = TRUE,
        add = FALSE)

\S4method{image3D}{SparseImagingExperiment}(x, formula, \dots, alpha.power = 2)

\S4method{image}{MSImagingExperiment}(x, formula,
        feature = features(x, mz=mz),
        feature.groups,
        mz,
        plusminus,
        \dots)

\S4method{image}{SparseImagingResult}(x, formula,
        model = modelData(x),
        superpose = is_matrix,
        \dots,
        column,
        colorscale = cividis,
        colorkey = !superpose,
        alpha.power = 2)

\S4method{image}{PCA2}(x, formula,
    values = "scores", \dots)

\S4method{image}{PLS2}(x, formula,
    values = c("fitted", "scores"), \dots)

\S4method{image}{SpatialFastmap2}(x, formula,
    values = "scores", \dots)

\S4method{image}{SpatialKMeans2}(x, formula,
    values = "cluster", \dots)

\S4method{image}{SpatialShrunkenCentroids2}(x, formula,
    values = c("probability", "class", "scores"), \dots)

\S4method{image}{SpatialDGMM}(x, formula,
    values = c("probability", "class", "mean"), \dots)

\S4method{image}{MeansTest}(x, formula,
    values = "mean", jitter = TRUE, \dots)

\S4method{image}{SegmentationTest}(x, formula,
    values = c("mean", "mapping"), jitter = TRUE, \dots)

\S4method{image}{AnnotatedImage}(x, frame = 1, offset = coord(x),
        height, width,
        layout = !add,
        native = TRUE,
        interpolate = TRUE,
        add = FALSE, \dots)

\S4method{image}{AnnotatedImageList}(x, i, frame = 1,
        strip = TRUE,
        layout = !add,
        native = TRUE,
        interpolate = TRUE,
        add = FALSE, \dots)

\S4method{image}{AnnotatedImagingExperiment}(x, i, frame = 1, \dots)
}

\arguments{
    
    \item{x}{An imaging dataset.}
    
    \item{formula}{A formula of the form 'z ~ x * y | g1 * g2 * ...' (or equivalently, 'z ~ x + y | g1 + g2 + ...'), indicating a LHS 'y' (on the y-axis) versus a RHS 'x' (on the x-axis) and conditioning variables 'g1, g2, ...'.

    Usually, the LHS is not supplied, and the formula is of the form '~ x * y | g1 * g2 * ...', and the y-axis is implicityl assumed to be the feature vectors corresponding to each pixel in the imaging dataset specified by the object 'x'. However, a variable evaluating to a vector of pixel values, or a sequence of such variables, can also be supplied.

    The RHS is evaluated in \code{pData(x)} and should provide values for the xy-axes. These must be spatial coordinates.

    The conditioning variables are evaluated in \code{fData(x)}. These can be specified in the formula as 'g1 * g2 * ...'. The argument 'feature.groups' allows an alternate way to specify a single conditioning variable. Conditioning variables specified using the formula interface will always appear on separate plots. This can be combined with 'superpose = TRUE' to both overlay plots based on a conditioning variable and use conditioning variables to create separate plots.}

    \item{data}{A \code{list} or \code{data.frame}-like object from which variables in \code{formula} should be taken.}

    \item{mz}{The m/z value(s) for which to plot the ion image(s).}

    \item{plusminus}{If specified, a window of m/z values surrounding the one given by \code{coord} will be included in the plot with \code{fun} applied over them, and this indicates the range of the window on either side.}
    
    \item{feature}{The feature or vector of features for which to plot the image. This is an expression that evaluates to a logical or integer indexing vector.}

    \item{feature.groups}{An alternative way to express a single conditioning variable. This is a variable or expression to be evaluated in \code{fData(x)}, expected to act as a grouping variable for the features specified by 'feature', typically used to distinguish different groups or ranges of features. Pixel vectors of images from features in the same feature group will have 'fun' applied over them; 'fun' will be applied to each feature group separately, usually for averaging. If 'superpose = FALSE' then these appear on separate plots.}

    \item{groups}{A variable or expression to be evaluated in \code{pData(x)}, expected to act as a grouping variable for the pixel regions in the image(s) to be plotted, typically used to distinguish different image regions by varying graphical parameters like color and line type. By default, if 'superpose = FALSE', these appear overlaid on the same plot.}

    \item{superpose}{Should feature vectors from different feature groups specified by 'feature.groups' be superposed on the same plot? If 'TRUE' then the 'groups' argument is ignored.}

    \item{strip}{Should strip labels indicating the plotting group be plotting along with the each panel? Passed to 'strip' in \code{\link{levelplot}} is 'lattice = TRUE'.}

    \item{key}{A logical, or \code{list} containing components to be used as a key for the plot. This is passed to 'key' in \code{\link{levelplot}} if 'lattice = TRUE'.}

    \item{fun}{A function to apply over pixel vectors of images grouped together by 'feature.groups'. By default, this is used for averaging over features.}

    \item{normalize.image}{Normalization function to be applied to each image. The function can be user-supplied, of one of 'none' or 'linear'. The 'linear' normalization method normalized each image to the same intensity range using a linear transformation.}

    \item{contrast.enhance}{Contrast enhancement function to be applied to each image. The function can be user-supplied, or one of 'none', 'histogram', or 'suppression'. The 'histogram' equalization method flatterns the distribution of intensities. The hotspot 'suppression' method uses thresholding to reduce the intensities of hotspots.}

    \item{smooth.image}{Image smoothing function to be applied to each image. The function can be user-supplied, or one of 'none', 'gaussian', or 'adaptive'. The 'gaussian' smoothing method smooths images with a simple gaussian kernel. The 'adaptive' method uses bilateral filtering to preserve edges.}

    \item{xlab}{Character or expression giving the label for the x-axis.}

    \item{ylab}{Character or expression giving the label for the y-axis.}

    \item{zlab}{Character or expression giving the label for the z-axis. (Only used for plotting 3D images.)}

    \item{xlim}{A numeric vector of length 2 giving the left and right limits for the x-axis.}

    \item{ylim}{A numeric vector of length 2 giving the top and bottom limits for the y-axis.}

    \item{zlim}{A numeric vector of length 2 giving the lower and upper limits for the z-axis (i.e., the range of colors to be plotted).}

    \item{layout}{The layout of the plots, given by a length 2 numeric as \code{c(ncol, nrow)}. This is passed to \code{\link{levelplot}} if 'lattice = TRUE'. For base graphics, this defaults to one plot per page.}

    \item{asp}{The aspect ratio of the plot.}

    \item{col}{A specification for the default plotting color(s) for groups.}

    \item{colorscale}{The color scale to use for the z-axis of image intensities. This may be either a vector of colors or a function which takes a single numeric argument \code{n} and generates a vector of colors of length \code{n}.}

    \item{colorkey}{Should a coloykey describing the z-axis be drawn with the plot?}

    \item{alpha.power}{Opacity scaling factor (1 is linear).}

    \item{jitter}{Should a small amount of noise be added to the image values before plotting them?}

    \item{subset}{An expression that evaluates to a logical or integer indexing vector to be evaluated in \code{pData(x)}.}
    
    \item{\dots}{Additional arguments passed to the underlying \code{\link{plot}} functions.}

    \item{i}{Which data element should be plotted.}

    \item{frame}{Which frame of an image should be plotted.}

    \item{offset}{Absolute offset in x/y coordinates of the top-left corner of the image (from the origin).}

    \item{height}{The height of the plotted image.}

    \item{width}{The width of the plotted image.}

    \item{native}{Should a native raster (using integer color codes) be produced, or an rgb raster (using character color codes)?}

    \item{interpolate}{Should any linear interpolation be done when plotting the image?}

    \item{model}{A vector or \code{list} specifying which fitted model to plot. If this is a vector, it should give a subset of the rows of \code{modelData(x)} to use for plotting. Otherwise, it should be a list giving the values of parameters in \code{modelData(x)}.}

    \item{values}{What kind of results should be plotted. This is the name of the object to plot in the \code{ImagingResult} object. Renamed from \code{mode} to avoid ambiguity.}

    \item{column}{What columns of the results should be plotted. If the results are a matrix, this corresponds to the columns to be plotted, which can be indicated either by numeric index or by name.}

    \item{add}{Should the method call \code{plot.new()} or be added to the current plot?}

}

\note{
    In most cases, calling \code{image3D(obj)} is equivalent to \code{image(obj, ~ x * y * z)}.
}

\author{
    Kylie A. Bemis
}

\seealso{
    \code{\link{plot}},
    \code{\link{selectROI}}
}

\examples{
setCardinalBPPARAM(SerialParam())

set.seed(1)
x <- simulateImage(preset=2, npeaks=10, dim=c(10,10))
m <- mz(metadata(x)$design$featureData)

image(x, mz=m[1], plusminus=0.5)
image(x, mz=m[1], smooth.image="gaussian", contrast.enhance="histogram")
image(x, mz=m[1], colorscale=col.map("grayscale"))
image(x, mz=m[4:7], colorscale=col.map("cividis"))
image(x, mz=m[c(1,8)], normalize.image="linear", superpose=TRUE)

sm <- summarizePixels(x, FUN=c(tic="sum"), as="DataFrame")
pData(x)$tic <- sm$tic

image(x, tic ~ x * y, colorscale=magma)
}

\keyword{hplot}

