
#### Delayed/batched pre-processing ####
## -------------------------------------

setMethod("process", "MSImagingExperiment",
	function(object, ..., delay = FALSE,
		outpath = NULL, imzML = FALSE)
	{
		if ( imzML && !delay ) {
			if ( !is.character(outpath) )
				.stop("valid outpath must be provided for imzML = TRUE")
			if ( nlevels(run(object)) > 1 )
				.stop("process() imzML output only possible for single-run experiments")
			queue <- .pendingQueue(processingData(object))
			if ( is.null(queue) ) {
				.warning("no pending processing steps to apply")
				return(object)
			}
			if ( "feature" %in% queue$info$kind )
				.stop("imzML output not allowed for feature processing: ",
					paste0(queue$info$label[queue$info$kind == "feature"], collapse=", "))
			if ( "global" %in% queue$info$kind )
				.stop("imzML output may be unexpected for global processing: ",
					paste0(queue$info$label[queue$info$kind == "global"], collapse=", "))
			# make file names
			path <- normalizePath(outpath, mustWork=FALSE)
			name <- basename(file_path_sans_ext(path))
			folder <- dirname(path)
			# make imzML filename
			xmlpath <- normalizePath(file.path(folder, paste(name, ".imzML", sep="")),
				mustWork=FALSE)
			if ( file.exists(xmlpath) )
				.warning("file ", xmlpath, " already exists and will be overwritten")
			# make ibd filename
			ibdpath <- normalizePath(file.path(folder, paste(name, ".ibd", sep="")),
				mustWork=FALSE)
			if ( file.exists(ibdpath) )
				.warning("file ", ibdpath, " already exists and will be overwritten")
			# make uuid
			id <- uuid(uppercase=FALSE)
			pid <- matter_vec(length=16, path=ibdpath, readonly=FALSE, type="raw")
			pid[] <- id$bytes
			# check output type
			if ( "peakPick" %in% queue$info$label ) {
				.message("[peakPick] detected in processing queue")
				.message("assuming 'processed' imzML output")
			} else {
				.message("assuming 'continuous' imzML output")
				fmeta <- metadata(featureData(object))
				if ( "mzBin" %in% queue$info$label ) {
					.message("detected [mzBin_ref]")
					mzref <- fmeta[["mzBin_ref"]]
				} else if ( "peakBin" %in% queue$info$label ) {
					.message("detected [peakBin_ref]")
					mzref <- fmeta[["peakBin_ref"]]
				} else {
					mzref <- mz(object)
				}
				if ( is.numeric(mzref) ) {
					.message("writing m/z values")
				} else {
					.stop("problem with m/z values")
				}
				warn <- getOption("matter.cast.warning")
				options(matter.cast.warning=FALSE)
				pmz <- matter_vec(offset=16, extent=length(mzref),
					path=ibdpath, readonly=FALSE, type="float")
				pmz[] <- mzref
				options(matter.cast.warning=warn)
			}
			# process
			object <- callNextMethod(object, ..., delay=delay,
									outpath=ibdpath)
			# write imzML
			info <- msiInfo(object, new=FALSE)
			.message("writing imzML file '", xmlpath, "'")
			result <- .writeImzML(info, xmlpath)
			if ( result )
				.message("done.")
		} else {
			object <- callNextMethod(object, ..., delay=delay,
									outpath=outpath)
		}
		object
	})

setMethod("process", "SparseImagingExperiment",
	function(object, fun, ...,
			kind = c("pixel", "feature", "global"),
			moreargs = NULL,
			prefun, preargs,
			postfun, postargs,
			plotfun,
			label = "",
			delay = FALSE,
			plot = FALSE,
			par = NULL,
			outpath = NULL,
			BPPARAM = getCardinalBPPARAM())
	{
		kind <- match.arg(kind)
		if ( missing(label) )
			label <- deparse(substitute(fun))
		if ( !missing(fun) || kind == "global" ) {
			# get fun
			if ( kind == "global" ) {
				fun <- NULL
			} else {
				fun <- .matchFunOrNULL(fun)
			}
			# get preproc
			if ( missing(prefun) ) {
				prefun <- NULL
			} else {
				prefun <- .matchFunOrNULL(prefun)
			}
			if ( missing(preargs) )
				preargs <- NULL
			# get postproc
			if ( missing(postfun) ) {
				postfun <- NULL
			} else {
				postfun <- .matchFunOrNULL(postfun)
			}
			if ( missing(postargs) )
				postargs <- NULL
			# get plotfun
			if ( missing(plotfun) ) {
				plotfun <- NULL
			} else {
				plotfun <- .matchFunOrNULL(plotfun)
			}
			# construct arglist
			args <- c(list(...), moreargs)
			# create processing list
			proclist <- list(
				fun=fun, args=args,
				prefun=prefun, preargs=preargs,
				postfun=postfun, postargs=postargs,
				plotfun=plotfun)
			# create processing info
			procinfo <- DataFrame(
				label=label, kind=kind,
				pending=TRUE, complete=FALSE,
				has_pre=!is.null(prefun),
				has_post=!is.null(postfun),
				has_plot=!is.null(plotfun))
			# update object
			i <- length(processingData(object)) + 1L
			if ( label %in% names(processingData(object)) ) {
				processingData(object)[[i]] <- proclist
			} else {
				processingData(object)[[label]] <- proclist
			}
			if ( is.null(mcols(processingData(object))) ) {
				mcols(processingData(object)) <- procinfo
			} else {
				mcols(processingData(object))[i,] <- procinfo
			}
			.logProcess(label, args, fun)
		}
		if ( !delay ) {
			if ( plot && !is(BPPARAM, "SerialParam") ) {
				.warning("plot=TRUE only allowed for SerialParam()")
				plot <- FALSE
				par <- NULL
			} else if ( plot && is.numeric(par$layout) ) {
				.setup.layout(par$layout)
				par$layout <- NULL
			}
			object <- .delayedBatchProcess(object,
				plot=plot, par=par, outpath=outpath,
				BPPARAM=BPPARAM)
		}
		if ( validObject(object) )
			object
	})

.delayedBatchProcess <- function(object, plot, par, outpath, BPPARAM)
{
	queue <- .pendingQueue(processingData(object))
	if ( is.null(queue) ) {
		.warning("no pending processing steps to apply")
		return(object)
	}
	.Cardinal$processing <- TRUE
	while ( !is.null(queue) ) {
		proclist <- queue$queue
		# perform preprocessing
		if ( any(queue$info$has_pre) ) {
			if ( getCardinalVerbose() )
				.message("preprocessing [", queue$info$label[1L], "] ...")
			prefun <- proclist[[1L]]$prefun
			preargs <- proclist[[1L]]$preargs
			prearglist <- c(list(object), preargs, list(BPPARAM=BPPARAM))
			object <- do.call(prefun, prearglist)
		}
		# apply processing to all pixels/features
		procfun <- function(.x, .list, .plot, .par, ...) {
			attr(.x, "mcols") <- featureData(object)
			for ( i in seq_along(.list) ) {
				has_plotfun <- !is.null(.list[[i]]$plotfun)
				fun <- .list[[i]]$fun
				arglist <- c(list(.x), .list[[i]]$args)
				.xnew <- do.call(fun, arglist)
				if ( .plot && has_plotfun ) {
					plotfun <- .list[[i]]$plotfun
					plotarglist <- c(list(.xnew), list(.x), .par)
					do.call(plotfun, plotarglist)
				}
				attributes(.xnew) <- attributes(.x)
				.x <- .xnew
			}
			attributes(.x) <- NULL
			.x
		}
		by_pixels <- "pixel" %in% queue$info$kind
		by_features <- "feature" %in% queue$info$kind
		if ( getCardinalVerbose() && (by_pixels || by_features) ) {
			labels <- paste0("[", queue$info$label, "]")
			.message("processing ", paste0(labels, collapse=" "), " ...")
		}
		if ( by_pixels ) {
			ans <- pixelApply(object, procfun,
				.list=proclist, .plot=plot, .par=par,
				.simplify=FALSE, .outpath=outpath,
				BPPARAM=BPPARAM)
		} else if ( by_features ) {
			ans <- featureApply(object, procfun,
				.list=proclist, .plot=plot, .par=par,
				.simplify=FALSE, .outpath=outpath,
				BPPARAM=BPPARAM)
		} else {
			ans <- NULL
		}
		# perform postprocessing
		if ( any(queue$info$has_post) ) {
			last <- length(proclist)
			if ( getCardinalVerbose() )
				.message("postprocessing [", queue$info$label[last], "] ...")
			postfun <- proclist[[last]]$postfun
			postargs <- proclist[[last]]$postargs
			postarglist <- c(list(object), list(ans),
				postargs, list(BPPARAM=BPPARAM))
			object <- do.call(postfun, postarglist)
		} else {
			if ( by_pixels ) {
				if ( is(ans, "matter_list") ) {
					iData(object) <- as(ans, "matter_mat")
				} else {
					iData(object) <- as.matrix(simplify2array(ans))	
				}
			} else if ( by_features ) {
				if ( is(ans, "matter_list") ) {
					iData(object) <- as(ans, "matter_matr")
				} else {
					iData(object) <- t(simplify2array(ans))
				}
			}
		}
		mcols(processingData(object))$pending[queue$index] <- FALSE
		mcols(processingData(object))$complete[queue$index] <- TRUE
		queue <- .pendingQueue(processingData(object))
	}
	.Cardinal$processing <- FALSE
	.message("done.")
	object
}

.logProcess <- function(label, args, fun) {
	method <- attr(fun, "method")
	if ( is.character(method) ) {
		s1 <- paste0("queued [", label, "] method = ", method)
	} else {
		s1 <- paste0("queued [", label, "]")
	}
	s2 <- sapply(seq_along(args), function(i) {
		paste0(names(args)[i], " : ", deparse(args[[i]]))
	})
	.log(paste0(c(s1, s2), collapse="\n"))
}

.pendingQueue <- function(y) {
	x <- y[mcols(y)$pending]
	if ( length(x) == 0L )
		return(NULL)
	if ( mcols(x)$kind[1L] == "global" ) {
		index <- which(mcols(y)$pending)[1L]
	} else {
		kind_ok <- mcols(x)$kind == mcols(x)$kind[1L]
		pre_ok <- !mcols(x)$has_pre
		pre_ok[1L] <- TRUE
		post_ok <- !mcols(x)$has_post
		post_ok <- c(TRUE, post_ok[-length(post_ok)])
		ok <- kind_ok & pre_ok & post_ok
		index <- which(mcols(y)$pending)[ok]
	}
	list(index=index, info=mcols(y)[index,], queue=y[index])
}

.checkForIncompleteProcessing <- function(object, message.only = FALSE) {
	anyPending <- any(mcols(processingData(object))$pending)
	if ( anyPending && !.Cardinal$processing ) {
		msg <- paste0("object has incomplete processing steps; ",
			"run process() on it to apply them")
		if ( message.only ) {
			.message("Note: ", msg)
		} else {
			.stop(msg)
		}
	}
}

