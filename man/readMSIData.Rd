\name{readMSIData}
\alias{readMSIData}
\alias{readImzML}
\alias{readAnalyze}

\title{Read mass spectrometry imaging data files}
\description{
	Read supported mass spectrometry imaging data files. Supported formats include imzML and Analyze 7.5.
}
\usage{
## Read any supported MS imaging file
readMSIData(file, \dots)

## Read imzML files
readImzML(name, folder = getwd(), attach.only = TRUE,
	mass.range = NULL, resolution = NA, units = c("ppm", "mz"),
	guess.max = 1000L, as = "MSImagingExperiment", parse.only = FALSE,
	BPPARAM = getCardinalBPPARAM(), \dots)

## Read Analyze 7.5 files
readAnalyze(name, folder = getwd(), attach.only = TRUE,
	as = "MSImagingExperiment", \dots)
}
\arguments{
	\item{file}{A description of the data file to be read. This may be either an absolute or relative path. The file extension must be included.}
	\item{name}{The common (base) file name for the '.imzML' and '.ibd' files for imzML or for the '.hdr', '.t2m', and '.img' files for Analyze 7.5.}
	\item{folder}{The path to the folder containing the data files.}
	\item{attach.only}{Attach the file as a \code{\linkS4class{matter}} on-disk matrix for reading on-demand, rather than loading the data into memory.}
	\item{mass.range}{For 'processed' imzML files, the mass range to use for the imported data. If known, providing this can improve the loading time dramatically, as otherwise it is calculated from reading the dataset directly.}
	\item{resolution}{For 'processed' imzML files, the accuracy to which the m/z values will be binned after reading. For \code{units="ppm"}, this is the half-binwidth, and should be set to the native accuracy of the mass spectrometer, if known. For \code{units="mz"}, this is simply the step size between m/z bins. If this is NA, then automatically guess a resolution from the data.}
	\item{units}{The units for \code{resolution}. Either parts-per-million or absolute m/z units.}
	\item{guess.max}{The number of spectra used when guessing the mass range and resolution.}
	\item{as}{After reading in the data, what class of object should be returned? As of Cardinal version >= 2.6, only \code{MSImagingExperiment} is supported.}
	\item{parse.only}{If TRUE, return only the parsed imzML metadata without creating a new imaging experiment object. (May be useful for diagnosing import problems.)}
	\item{BPPARAM}{An optional instance of \code{BiocParallelParam}. See documentation for \code{\link{bplapply}}. This is only used when \code{mass.range=NULL} and \code{attach.only=TRUE}, when reading the mass range from the m/z data of a "processed" imzML file.}
	\item{\dots}{Additional arguments passed to read functions.}
}
\details{
	In the current implementation, the file extensions must match exactly: '.imzML' and '.ibd' for imzML and '.hdr', '.t2m', and '.img' for Analyze 7.5.

	The \code{readImzML} function supports reading and returning both the 'continuous' and 'processed' formats.

	When \code{attach.only=TRUE}, the data is not loaded into memory; only the experimental metadata is read, and the intensity data will only be accessed on-demand. For large datasets, this is memory-efficient. For smaller datasets, this may be slower than simply reading the entire dataset into memory.

	If the mass range is known, setting \code{mass.range} will make reading data much faster for very large datasets.

	If problems are encountered while trying to import imzML files, the files should be verified and fixed with the Java-based imzMLValidator application: https://gitlab.com/imzML/imzMLValidator/.
}
\value{
	A \code{\linkS4class{MSImagingExperiment}} object.
}
\author{
	Kylie A. Bemis
}
\references{
    Schramm T, Hester A, Klinkert I, Both J-P, Heeren RMA, Brunelle A, Laprevote O, Desbenoit N, Robbe M-F, Stoeckli M, Spengler B, Rompp A (2012) imzML - A common data format for the flexible exchange and processing of mass spectrometry imaging data. Journal of Proteomics 75 (16):5106-5110. doi:10.1016/j.jprot.2012.07.026
}
\seealso{
	\code{\link{writeMSIData}}
}
\keyword{IO}
