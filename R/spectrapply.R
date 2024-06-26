
#### Row/column apply ####
## ------------------------

setMethod("spectrapply", "MSImagingExperiment",
	function(object, FUN, ...,
		spectra = "intensity", index = "mz")
	{
		callNextMethod(object, FUN=FUN, ...,
			spectra=spectra, index=index)
	})

setMethod("spectrapply", "MSImagingArrays",
	function(object, FUN, ...,
		spectra = "intensity", index = "mz")
	{
		callNextMethod(object, FUN=FUN, ...,
			spectra=spectra, index=index)
	})

setMethod("spectrapply", "SpectralImagingExperiment",
	function(object, FUN, ...,
		spectra = "intensity", index = NULL,
		simplify = TRUE, outpath = NULL,
		nchunks = getCardinalNChunks(),
		verbose = getCardinalVerbose(),
		BPPARAM = getCardinalBPPARAM())
	{
		if ( length(processingData(object)) > 0L )
			warning("processing steps will be ignored by spectrapply()")
		if ( length(index) > 1L )
			stop("more than 1 'index' array not allowed ",
				"for class ", sQuote(class(object)[1L]))
		snm <- spectra
		inm <- index
		spectra <- spectra(object, snm)
		if ( is.null(inm) ) {
			inm <- "index"
			index <- seq_len(nrow(object))
		} else {
			index <- featureData(object)[[inm]]
			if ( is.null(index) )
				stop("index ", sQuote(inm), " not found")
		}
		if ( ...length() > 0L && is.null(...names()) )
			stop("spectrapply() arguments passed via ... must be named")
		chunkApply(spectra, 2L, FUN, index, ...,
			simplify=simplify, outpath=outpath,
			nchunks=nchunks, verbose=verbose,
			BPPARAM=BPPARAM)
	})

setMethod("spectrapply", "SpectralImagingArrays",
	function(object, FUN, ...,
		spectra = "intensity", index = NULL,
		simplify = TRUE, outpath = NULL,
		nchunks = getCardinalNChunks(),
		verbose = getCardinalVerbose(),
		BPPARAM = getCardinalBPPARAM())
	{
		if ( length(processingData(object)) > 0L )
			warning("processing steps will be ignored by spectrapply()")
		if ( length(index) > 3L )
			stop("more than 3 'index' arrays not allowed ",
				"for class ", sQuote(class(object)[1L]))
		nindex <- max(1L, length(index))
		snm <- spectra
		inm <- index
		spectra <- spectra(object, snm)
		if ( is.null(inm) ) {
			inm <- "index"
			index <- lapply(lengths(spectra), seq_len)
		} else {
			index <- spectra(object, inm[1L])
			if ( is.null(index) )
				stop("index ", sQuote(inm[1L]), " not found")
			if ( nindex >= 2L ) {
				index2 <- spectra(object, inm[2L])
				if ( is.null(index2) )
					stop("index ", sQuote(inm[2L]), " not found")
			}
			if ( nindex >= 3L ) {
				index3 <- spectra(object, inm[3L])
				if ( is.null(index2) )
					stop("index ", sQuote(inm[3L]), " not found")
			}
		}
		if ( ...length() > 0L && is.null(...names()) )
			stop("spectrapply() arguments passed via ... must be named")
		args <- list(...)
		if ( nindex == 1L ) {
			chunkMapply(FUN, spectra, index, MoreArgs=args,
				simplify=simplify, outpath=outpath,
				nchunks=nchunks, verbose=verbose,
				BPPARAM=BPPARAM)
		} else if ( nindex == 2L ) {
			chunkMapply(FUN, spectra, index, index2, MoreArgs=args,
				simplify=simplify, outpath=outpath,
				nchunks=nchunks, verbose=verbose,
				BPPARAM=BPPARAM)
		} else if ( nindex == 3L ) {
			chunkMapply(FUN, spectra, index, index2, index3, MoreArgs=args,
				simplify=simplify, outpath=outpath,
				nchunks=nchunks, verbose=verbose,
				BPPARAM=BPPARAM)
		} else {
			stop("too many 'index' arrays")
		}
	})

