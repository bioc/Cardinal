
#### Estimate shared domain ####
## ------------------------------

estimateDomain <- function(xlist,
	width = c("median", "min", "max", "mean"),
	units = c("relative", "absolute"),
	verbose = getCardinalVerbose(), chunkopts = list(),
	BPPARAM = getCardinalBPPARAM(), ...)
{
	units <- match.arg(units)
	width <- match.arg(width)
	ref <- switch(units, relative="x", absolute="abs")
	FUN <- isofun(function(x, ref) {
		x <- x[!is.na(x)]
		res <- unname(estres(x, ref=ref))
		if ( length(x) > 0 && is.finite(res) ) {
			c(min=min(x), max=max(x), res=res)
		} else {
			c(min=NA_real_, max=NA_real_, res=res)
		}
	}, CardinalEnv())
	ans <- chunkLapply(xlist, FUN, ref=ref,
		verbose=verbose, chunkopts=chunkopts,
		BPPARAM=BPPARAM, ...)
	ans <- do.call(rbind, ans)
	from <- floor(min(ans[,1L], na.rm=TRUE))
	to <- ceiling(max(ans[,2L], na.rm=TRUE))
	by <- match.fun(width)(ans[,3L], na.rm=TRUE)
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
	width = c("median", "min", "max", "mean"),
	units = c("ppm", "mz"),
	verbose = getCardinalVerbose(), chunkopts = list(),
	BPPARAM = getCardinalBPPARAM(), ...)
{
	if ( length(processingData(object)) > 0L )
		.Warn("queued processing steps will be ignored")
	if ( is(object, "MSImagingExperiment") || is(object, "MassDataFrame") ) {
		mz(object)
	} else if ( is(object, "MSImagingArrays") ) {
		units <- match.arg(units)
		units <- switch(units, ppm="relative", mz="absolute")
		estimateDomain(mz(object), width=width, units=units,
			verbose=verbose, chunkopts=chunkopts,
			BPPARAM=BPPARAM, ...)
	} else {
		.Error("can't estimate m/z values for class ", sQuote(class(object)))
	}
}

estimateReferencePeaks <- function(object, SNR = 2,
	method = c("diff", "sd", "mad", "quantile", "filter", "cwt"),
	verbose = getCardinalVerbose(), chunkopts = list(),
	BPPARAM = getCardinalBPPARAM(), ...)
{
	if ( length(processingData(object)) > 0L )
		.Warn("queued processing steps will be ignored")
	method <- match.arg(method)
	if ( is(object, "MSImagingArrays") ) {
		object <- convertMSImagingArrays2Experiment(object,
			verbose=verbose, chunkopts=chunkopts,
			BPPARAM=BPPARAM, ...)
	}
	object <- summarizeFeatures(object, stat="mean",
		verbose=verbose, chunkopts=chunkopts,
		BPPARAM=BPPARAM)
	featureData <- featureData(object)
	peaks <- findpeaks(featureData[["mean"]], noise=method, snr=SNR, ...)
	featureData[peaks,,drop=FALSE]
}




