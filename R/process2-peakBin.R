
#### Bin spectra to reference peaks ####
## ------------------------------------

setMethod("peakBin", c("MSImagingExperiment", "numeric"),
	function(object, ref, type=c("area", "height"),
		tolerance = NA, units = c("ppm", "mz"), ...)
	{
		units <- match.arg(units)
		if ( is.na(tolerance) )
			tolerance <- .estimateMassResolution(mz(object), units)
		tol <- switch(units,
			ppm = c("relative" = unname(tolerance) * 1e-6),
			mz = c("absolute" = unname(tolerance)))
		tol.ref <- switch(names(tol),
			relative = "x",
			absolute = "abs")
		type <- match.arg(type)
		metadata(featureData(object))[["peakBin_ref"]] <- ref
		object <- process(object, fun=peakBin_fun,
			label="peakBin", kind="pixel",
			moreargs=list(type=type, tol=tol, tol.ref=tol.ref),
			postfun=peakBin_postfun, postargs=list(tol=tol),
			plotfun=peakBin_plotfun,
			delay=getCardinalDelayProc())
		object
	})

setMethod("peakBin", c("MSImagingExperiment", "missing"),
	function(object, type=c("area", "height"),
		tolerance = NA, units = c("ppm", "mz"), ...)
	{
		units <- match.arg(units)
		if ( is.na(tolerance) )
			tolerance <- .estimateMassResolution(mz(object), units)
		tol <- switch(units,
			ppm = c("relative" = unname(tolerance) * 1e-6),
			mz = c("absolute" = unname(tolerance)))
		type <- match.arg(type)
		object <- process(object, fun=peakBin_fun,
			label="peakBin", kind="pixel",
			moreargs=list(type=type, tol=tol, mz=NULL, peaks=NULL),
			prefun=peakBin_prefun, plotfun=peakBin_plotfun,
			postfun=peakBin_postfun, postargs=list(tol=tol),			
			delay=getCardinalDelayProc())
		object
	})

peakBin_fun <- function(x, type, tol, tol.ref, ...) {
	mz <- mz(attr(x, "mcols"))
	ref <- metadata(attr(x, "mcols"))[["peakBin_ref"]]
	if ( is.null(ref) )
		.stop("couldn't find reference peaks")
	maxs <- findpeaks(x)
	l1 <- attr(maxs, "left_bounds")
	l2 <- attr(maxs, "right_bounds")
	f <- switch(type, height="max", area="sum")
	matches <- bsearch(ref, mz[maxs], tol=tol, tol.ref=tol.ref)
	peaks <- binvec(x, l1, l2, stat=f)
	peaks <- peaks[matches]
	peaks[is.na(peaks)] <- 0
	attr(peaks, "bins") <- list(lower=l1[matches], upper=l2[matches])
	peaks
}

peakBin_prefun <- function(object, ..., BPPARAM) {
	s <- rowStats(spectra(object), stat="mean",
		nchunks=getCardinalNumBlocks(),
		verbose=getCardinalVerbose(),
		BPPARAM=BPPARAM)
	ref <- mz(object)[findpeaks(s)]
	metadata(featureData(object))[["peakBin_ref"]] <- ref
	object
}

peakBin_postfun <- function(object, ans, tol, ...) {
	if ( is.matter(ans) ) {
		data <- as(ans, "matter_mat")
	} else {
		data <- as.matrix(simplify2array(ans))
	}
	ref <- metadata(featureData(object))[["peakBin_ref"]]
	if ( is.null(ref) )
		.stop("couldn't find reference peaks")
	mcols <- MassDataFrame(mz=ref)
	res <- switch(names(tol),
			relative = c(ppm = unname(tol) / 1e-6),
			absolute = c(mz = 2 * unname(tol)))
	metadata(mcols) <- metadata(featureData(object))
	object <- MSImagingExperiment(data,
		featureData=mcols,
		pixelData=pixelData(object),
		metadata=metadata(object),
		processing=processingData(object),
		centroided=TRUE)
	tol <- switch(names(tol),
		relative = c(ppm = unname(tol) / 1e-6),
		absolute = c(mz = unname(tol)))
	resolution(featureData(object)) <- 2 * tol
	if ( !is.null(spectrumRepresentation(object)) )
		spectrumRepresentation(object) <- "centroid spectrum"
	.message("binned to ", length(ref), " reference peaks ",
		"(tol = ", tol, " ",  names(tol), ")")
	object
}

peakBin_plotfun <- function(s2, s1, ...,
	main="Peak binning", xlab="m/z", ylab="")
{
	mz <- mz(attr(s1, "mcols"))
	ref <- metadata(attr(s1, "mcols"))[["peakBin_ref"]]
	if ( is.null(ref) )
		.stop("couldn't find reference peaks")
	plot(range(mz), range(s2), main=main,
		xlab=xlab, ylab=ylab, type='n', ...)
	lines(mz, s1, col="gray", type='l')
	bins <- attr(s2, "bins")
	if ( !is.null(bins) ) {
		i <- unique(unlist(mapply(":", bins[[1]], bins[[2]])))
		lines(mz[i], s1[i], col=rgb(0, 0, 1, 0.25), type='h')
	}
	lines(ref, s2, col="red", type='h')
}
