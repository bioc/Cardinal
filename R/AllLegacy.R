
#### Legacy Cardinal 1.0 classes ####
## These classes and methods operating on them are
## now deprecated; the class definitions will remain
## for backward-compatibility with CardinalWorkflows
## and to support coercion/updating to newer classes
.Deprecated_Cardinal1 <- function(class1 = "MSImageSet",
								class2 = "MSImagingExperiment") {
	msg <- paste0("The ", sQuote(class1), " class is deprecated.")
	if ( (missing(class1) && missing(class1)) || !missing(class2) ) {
		msg <- paste0(msg, "\nUse as(object, ", sQuote(class2), ") to\n",
			"return an updated version of this object.")
	}
	.Deprecated(msg=msg)
}

#### Pixel based AnnotatedDataFrame for imaging ####
## based on Biobase's AnnotatedDataFrame, but with 
## additions that reflect that each row belongs to a pixel
## and multiple rows will belong to the same sample
## ------------------------------------------------
.IAnnotatedDataFrame <- setClass("IAnnotatedDataFrame",
	contains = "AnnotatedDataFrame",
	prototype = prototype(new("Versioned",
		versions=c(IAnnotatedDataFrame="0.1.0"))))

#### 'Minimum Information About a Proteomics Experiment' - Imaging ####
## based on working MIAPE-Imaging document and imzML specification
## ---------------------------------------------------------------
setClass("MIAPE-Imaging",
	slots = c(
		## Experimental Info
		title = "character",
		abstract = "character",
		url = "character",
		pubMedIds = "character",
		preprocessing = "list", # pre-processing NOT performed by Cardinal
		other = "list",
		## Responsible Person
		name = "character",
		lab = "character",
		contact = "character",
		## Histomorphological Classification
		samples = "list", # sample ids
		specimenOrigin = "character", # institution
		specimenType = "character", # species, organ, ...
		stainingMethod = "character", # H&E, etc.
		## Tissue Preparation
		tissueThickness = "numeric",
		tissueWash = "character",
		embeddingMethod = "character",
		inSituChemistry = "character", # tryptic digest, ...
		matrixApplication = "character", # application method
		## Data Acquisition: Instrument Details
		pixelSize = "numeric",
		instrumentModel = "character",
		instrumentVendor = "character",
		massAnalyzerType = "character", # TOF, LTQ, ...
		ionizationType = "character", # MALDI, DESI, ...
		scanPolarity = "character",
		## Data Acquisition: Control Software
		softwareName = "character",
		softwareVersion = "character",
		## Data Acquisition: Scan Settings
		scanType = "character",
		scanPattern = "character",
		scanDirection = "character",
		lineScanDirection = "character",
		imageShape = "character"),
	contains = "MIAxE",
	prototype = prototype(
		new("Versioned", versions=c(classVersion("MIAxE"),
			`MIAPE-Imaging`="0.1.0"))))

#### Class for pre-processing information for an 'MSImageSet' ####
## should store all of the calls and their parameters
## --------------------------------------------------
setClass("MSImageProcess",
	slots = c(
		files = "character",
		normalization = "character",
		smoothing = "character",
		baselineReduction = "character",
		spectrumRepresentation = "character",
		peakPicking = "character",
		centroided = "logical",
		history = "list",
		CardinalVersion = "character"),
	contains = "Versioned",
	prototype = prototype(
		new("Versioned", versions=c(MSImageProcess="0.1.0")),
		centroided = logical(1), # set up when reading dataset
		CardinalVersion = character())) # set up in initialize

#### Class for generic imaging data ###
## simply holds an environment and a storage mode
## where elements of the environment are arrays
## --------------------------------------------
.ImageData <- setClass("ImageData",
	slots = c(
		data = "environment",
		storageMode = "character"),
	contains = "Versioned",
	prototype = prototype(
		new("Versioned", versions=c(ImageData="0.1.0")),
		data = new.env(parent=emptyenv()), # re-assign in initialize
		storageMode = "immutableEnvironment"))

#### Class for holding sparse image data ####
## feature vectors are stored as a matrix and the datacube
## can be reconstructed as an array on-the-fly
## --------------------------------------------
.SImageData <- setClass("SImageData",
	slots = c(
		coord = "data.frame",
		positionArray = "array",
		dim = "numeric",
		dimnames = "list"),
	contains = "ImageData",
	prototype = prototype(
		new("Versioned", versions=c(classVersion("ImageData"),
			SImageData="0.1.0")),
		coord = data.frame(x=numeric(), y=numeric()),
		positionArray = array(0, dim=c(x=0, y=0)),
		dim = c(0, 0),
		dimnames = list(NULL, NULL)))

#### Class for MS imaging data ###
## allows methods for retrieving peak cubes, etc.
## ----------------------------------------------
.MSImageData <- setClass("MSImageData",
	contains = "SImageData",
	prototype = prototype(
		new("Versioned", versions=c(classVersion("ImageData"),
			classVersion("SImageData"), MSImageData="0.1.0")),
		coord = data.frame(x=numeric(), y=numeric()),
		positionArray = array(0, dim=c(x=0, y=0)),
		dim = c(0, 0),
		dimnames = list(NULL, NULL)))

#### Matrix-like class for sparse signals ####
## implemented using lists as hash tables
## ---------------------------------------
.Hashmat <- setClass("Hashmat",
	slots = c(
		data = "list",
		keys = "character",
		dim = "numeric",
		dimnames = "list"),
	contains = "Versioned",
	prototype = prototype(
		new("Versioned", versions=c(Hashmat="0.1.0")),
		data = list(),
		keys = character(),
		dim = c(0, 0),
		dimnames = list(NULL, NULL)))

#### Class for generic imaging datasets ####
## heavily inspired by structure of Biobase's eSet
## ------------------------------------------------
setClass("iSet",
	slots = c(
		imageData = "ImageData", # holds an immutable environment
		pixelData = "IAnnotatedDataFrame", # analogous to phenoData
		featureData = "AnnotatedDataFrame",
		experimentData = "MIAxE",
		protocolData = "AnnotatedDataFrame"),
	contains = c("VersionedBiobase", "VIRTUAL"),
	prototype = prototype(
		new("VersionedBiobase", versions=c(iSet="0.1.0")),
		imageData = .ImageData(),
		pixelData = .IAnnotatedDataFrame(
			dimLabels = c("pixelNames", "pixelColumns")),
		featureData = new("AnnotatedDataFrame",
			dimLabels = c("featureNames", "featureColumns")),
		protocolData = new("AnnotatedDataFrame",
			dimLabels = c("sampleNames", "sampleColumns"))))

#### Class for pixel-sparse imaging datasets ####
## extends iSet with metadata and methods for MS imaging
## ----------------------------------------------------
.SImageSet <- setClass("SImageSet",
	slots = c(imageData = "SImageData"),
	contains = "iSet",
	prototype = prototype(
		new("VersionedBiobase", versions=c(classVersion("iSet"),
			SImageSet="0.1.0")),
		imageData = .SImageData()))

#### Class for mass spectrometry imaging datasets ####
## extends SImageSet with metadata for MS imaging
## ----------------------------------------------
.MSImageSet <- setClass("MSImageSet",
	slots = c(
		processingData = "MSImageProcess",
		experimentData = "MIAPE-Imaging"),
	contains = "SImageSet",
	prototype = prototype(
		new("VersionedBiobase", versions=c(classVersion("iSet"),
			classVersion("SImageSet"), MSImageSet="0.7.0")),
		imageData = .MSImageData(),
		processingData = new("MSImageProcess"),
		experimentData = new("MIAPE-Imaging")))

#### Classes for collections of experimental analysis results ####
## ---------------------------------------------------------------
setClass("ResultSet",
	slots = c(
		resultData = "list",
		modelData = "AnnotatedDataFrame"),
	contains = c("iSet", "VIRTUAL"),
	prototype = prototype(
		new("VersionedBiobase", versions=c(classVersion("iSet"),
			ResultSet="0.1.0"))))

setClass("CrossValidated", contains="ResultSet")

## define 2.x classes for installation

setClass("PCA2")
setClass("PLS2")
setClass("OPLS2")
setClass("SpatialFastmap2")
setClass("SpatialKMeans2")
setClass("SpatialShrunkenCentroids2")
setClass("CrossValidated2")

## coerce from MSImageSet

.from_legacy_MSImagSet <- function(from)
{
	fData <- from@featureData
	pData <- from@pixelData
	fDataNames <- setdiff(names(fData), "mz")
	coordLabelTypes <- "dim"
	sampleLabelTypes <- "sample"
	isCoord <- pData@varMetadata[["labelType"]] %in% coordLabelTypes
	isCoord[names(pData@data) %in% sampleLabelTypes] <- FALSE
	coordLabels <- names(pData@data)[isCoord]
	pDataNames <- setdiff(names(pData@data), c(coordLabels, "sample"))
	iData <- from@imageData@data[["iData"]]
	MSImagingExperiment(spectraData=iData,
		featureData=MassDataFrame(
			mz=fData@data[["mz"]],
			fData@data[,fDataNames,drop=FALSE]),
		pixelData=PositionDataFrame(
			coord=DataFrame(pData@data[isCoord], row.names=NULL),
			run=pData@data$sample,
			pData@data[,pDataNames,drop=FALSE]),
		centroided=from@processingData@centroided)
}

setAs("MSImageSet", "MSImagingExperiment", .from_legacy_MSImagSet)

