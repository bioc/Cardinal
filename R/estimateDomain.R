
#### Estimate shared domain ####
## ------------------------------

estimateDomain <- function(xlist,
	units = c("relative", "absolute"),
	nchunks = getCardinalNChunks(),
	verbose = getCardinalVerbose(),
	BPPARAM = getCardinalBPPARAM(), ...)
{
	units <- match.arg(units)
	ref <- switch(units, relative="x", absolute="abs")
	FUN <- function(x) {
		x <- x[!is.na(x)]
		res <- unname(estres(x, ref=ref))
		if ( length(x) > 0 && is.finite(res) ) {
			c(min=min(x), max=max(x), res=res)
		} else {
			c(min=NA_real_, max=NA_real_, res=res)
		}
	}
	ans <- chunkLapply(xlist, FUN,
		nchunks=nchunks, verbose=verbose,
		BPPARAM=BPPARAM, ...)
	ans <- do.call(rbind, ans)
	from <- floor(min(ans[,1L], na.rm=TRUE))
	to <- ceiling(max(ans[,2L], na.rm=TRUE))
	by <- median(ans[,3L], na.rm=TRUE)
	by <- switch(units,
		relative=round(2 * by, digits=6L) * 0.5,
		absolute=round(by, digits=4L))
	ans <- switch(units,
		relative=seq_rel(from, to, by=by),
		absolute=seq.default(from, to, by=by))
	structure(as.vector(ans),
		resolution = setNames(by, units))
}

estimateReferenceMz <- function(object,
	units = c("ppm", "mz"),
	nchunks = getCardinalNChunks(),
	verbose = getCardinalVerbose(),
	BPPARAM = getCardinalBPPARAM(), ...)
{
	if ( length(processingData(object)) > 0L )
		warning("processing steps will be ignored by estimateReferenceMz()")
	if ( is(object, "MSImagingExperiment") || is(object, "MassDataFrame") ) {
		mz(object)
	} else if ( is(object, "MSImagingArrays") ) {
		units <- match.arg(units)
		units <- switch(units, ppm="relative", mz="absolute")
		estimateDomain(mz(object), units=units,
			nchunks=nchunks, verbose=verbose, BPPARAM=BPPARAM, ...)
	} else {
		stop("can't estimate m/z values for class ", sQuote(class(object)))
	}
}

estimateReferencePeaks <- function(object, SNR = 2,
	method = c("diff", "sd", "mad", "quantile", "filter", "cwt"),
	nchunks = getCardinalNChunks(),
	verbose = getCardinalVerbose(),
	BPPARAM = getCardinalBPPARAM(), ...)
{
	if ( length(processingData(object)) > 0L )
		warning("processing steps will be ignored by estimateReferencePeaks()")
	method <- match.arg(method)
	object <- summarizeFeatures(object, stat="mean",
		nchunks=nchunks, verbose=verbose,
		BPPARAM=BPPARAM)
	featureData <- featureData(object)
	peaks <- findpeaks(featureData[["mean"]], noise=method, snr=SNR, ...)
	featureData[peaks,,drop=FALSE]
}




