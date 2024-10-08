require(testthat)
require(Cardinal)
 
context("process-peaks")

test_that("process peaks - SpectralImagingArrays", {

	path <- CardinalIO::exampleImzMLFile("processed")
	s <- as(readImzML(path), "SpectralImagingArrays")

	s2 <- peakPick(s, method="sd")
	s2 <- process(s2)
	n1 <- lengths(spectra(s, "index"))
	n2 <- lengths(spectra(s2, "index"))

	expect_is(s2, "SpectralImagingArrays")
	expect_true(all(n2 < n1))

	s3 <- peakPick(s, method="cwt")
	s3 <- process(s3)
	n3 <- lengths(spectra(s3, "index"))

	expect_true(all(n3 < n1))
	expect_is(s3, "SpectralImagingArrays")

	s4 <- peakAlign(s3, index="index", units="relative")
	s5 <- peakAlign(s3, index="index", units="absolute")

	expect_is(s4, "SpectralImagingExperiment")
	expect_is(s5, "SpectralImagingExperiment")

})

test_that("process peaks - SpectralImagingExperiment", {

	path <- CardinalIO::exampleImzMLFile("continuous")
	s <- as(readImzML(path), "SpectralImagingExperiment")

	s2 <- peakPick(s, method="sd")
	s2 <- process(s2)
	n1 <- lengths(matter::atomdata(spectra(s)))
	n2 <- lengths(matter::atomdata(spectra(s2)))

	expect_is(s2, "SpectralImagingExperiment")
	expect_is(spectra(s2), "sparse_mat")
	expect_true(all(n2 < n1))

	s3 <- peakPick(s, method="cwt")
	s3 <- process(s3)
	n3 <- lengths(matter::atomdata(spectra(s3)))

	expect_is(s3, "SpectralImagingExperiment")
	expect_is(spectra(s3), "sparse_mat")
	expect_true(all(n3 < n1))

	s4 <- peakAlign(s3, units="relative")
	s5 <- peakAlign(s3, units="absolute")

	expect_is(s4, "SpectralImagingExperiment")
	expect_is(s5, "SpectralImagingExperiment")
	
})

test_that("process peaks - MSImagingArrays", {

	path <- CardinalIO::exampleImzMLFile("processed")
	ms <- readImzML(path)

	ms2 <- peakPick(ms, method="sd")
	ms2 <- process(ms2)
	n1 <- lengths(intensity(ms))
	n2 <- lengths(intensity(ms2))

	expect_is(ms2, "MSImagingArrays")
	expect_true(all(n2 < n1))

	ms3 <- peakPick(ms, method="cwt")
	ms3 <- process(ms3)
	n3 <- lengths(intensity(ms3))

	expect_is(ms3, "MSImagingArrays")
	expect_true(all(n3 < n1))

	ms4 <- bin(ms, units="mz")
	ms4 <- summarizeFeatures(ms4)
	peaks <- matter::findpeaks(fData(ms4)$mean, snr=6)
	peaks <- mz(ms4)[peaks]
	ms5 <- peakPick(ms, ref=peaks)
	ms5 <- process(ms5, domain=peaks)
	n4 <- nrow(ms5)

	expect_equal(n4, length(peaks))
	expect_is(ms5, "MSImagingExperiment")
	expect_is(spectra(ms5), "matrix")

	ms6 <- peakAlign(ms3, units="ppm")
	ms7 <- peakAlign(ms3, units="mz")
	ms8 <- peakAlign(ms3, tolerance=1, units="mz")
	ms9 <- peakAlign(ms3, ref=peaks)

	expect_is(ms6, "MSImagingExperiment")
	expect_is(ms7, "MSImagingExperiment")
	expect_is(ms8, "MSImagingExperiment")
	expect_is(ms9, "MSImagingExperiment")
	expect_equal(mz(ms9), peaks)

	ms10 <- peakProcess(ms)
	ms11 <- peakProcess(ms, sampleSize=0.1, filterFreq=FALSE)
	ms12 <- peakProcess(ms, ref=ms5)

	expect_is(ms10, "MSImagingExperiment")
	expect_is(ms11, "MSImagingExperiment")
	expect_is(ms12, "MSImagingExperiment")
	expect_is(spectra(ms10), "sparse_mat")
	expect_is(spectra(ms11), "matrix")
	expect_is(spectra(ms12), "matrix")

	ms13 <- peakAlign(ms3, tolerance=0.1, units="mz")
	ms14 <- peakAlign(ms13, ref=ms13, tolerance=0.1, units="mz")

	expect_equal(ms13, ms14)

})

test_that("process peaks - MSImagingExperiment", {

	path <- CardinalIO::exampleImzMLFile("continuous")
	ms <- readImzML(path)

	ms2 <- peakPick(ms, method="sd")
	ms2 <- process(ms2)
	n1 <- lengths(matter::atomdata(spectra(ms)))
	n2 <- lengths(matter::atomdata(spectra(ms2)))

	expect_is(ms2, "MSImagingExperiment")
	expect_true(all(n2 < n1))

	ms3 <- peakPick(ms, method="cwt")
	ms3 <- process(ms3)
	n3 <- lengths(matter::atomdata(spectra(ms3)))

	expect_is(ms3, "MSImagingExperiment")
	expect_true(all(n3 < n1))

	ms4 <- summarizeFeatures(ms)
	peaks <- matter::findpeaks(fData(ms4)$mean, snr=6)
	peaks <- mz(ms4)[peaks]
	ms5 <- peakPick(ms, ref=peaks)
	ms5 <- process(ms5, domain=peaks)
	n4 <- nrow(ms5)

	expect_equal(n4, length(peaks))
	expect_is(ms5, "MSImagingExperiment")
	expect_is(spectra(ms5), "matrix")

	ms6 <- peakAlign(ms3, units="ppm")
	ms7 <- peakAlign(ms3, units="mz")
	ms8 <- peakAlign(ms3, tolerance=1, units="mz")
	ms9 <- peakAlign(ms3, ref=peaks)

	expect_is(ms6, "MSImagingExperiment")
	expect_is(ms7, "MSImagingExperiment")
	expect_is(ms8, "MSImagingExperiment")
	expect_is(ms9, "MSImagingExperiment")
	expect_equal(mz(ms9), peaks)

	ms10 <- peakProcess(ms)
	ms11 <- peakProcess(ms, sampleSize=0.1, filterFreq=FALSE)
	ms12 <- peakProcess(ms, ref=ms5)

	expect_is(ms10, "MSImagingExperiment")
	expect_is(ms11, "MSImagingExperiment")
	expect_is(ms12, "MSImagingExperiment")
	expect_is(spectra(ms10), "sparse_mat")
	expect_is(spectra(ms11), "matrix")
	expect_is(spectra(ms12), "matrix")

	ms13 <- peakAlign(ms3, tolerance=0.1, units="mz")
	ms14 <- peakAlign(ms13, ref=ms13, tolerance=0.1, units="mz")

	expect_equal(ms13, ms14)

	ms15 <- peakProcess(ms10, ms10)
	ms16 <- peakProcess(ms11)

	expect_equal(ms10, ms15)
	expect_equal(ms11, ms16)

})
