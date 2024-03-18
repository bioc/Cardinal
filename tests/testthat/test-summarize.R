require(testthat)
require(Cardinal)

context("summarize")

test_that("spectrapply", {

	path <- CardinalIO::exampleImzMLFile("continuous")
	mse <- readImzML(path, memory=TRUE)

	xout <- spectrapply(mse, function(x, t, ...) x)
	mzout <- spectrapply(mse, function(x, t, ...) t)

	expect_equal(spectra(mse), xout)
	expect_equal(mz(mse), mzout[,1L])

	path2 <- CardinalIO::exampleImzMLFile("processed")
	mse2 <- readImzML(path2, memory=TRUE)

	xout2 <- spectrapply(mse2, function(x, t, ...) x, simplify=FALSE)
	mzout2 <- spectrapply(mse2, function(x, t, ...) t, simplify=FALSE)

	expect_equal(intensity(mse2), xout2)
	expect_equal(mz(mse2), mzout2)

})

test_that("summarizeFeatures", {

	register(SerialParam())

	path <- CardinalIO::exampleImzMLFile("continuous")
	mse <- readImzML(path, memory=TRUE)
	g <- makeFactor(A=mse$y==1, B=mse$y==2, C=mse$y==3)

	mse <- summarizeFeatures(mse)
	mse <- summarizeFeatures(mse, groups=g)

	expect_equal(fData(mse)$mean, rowMeans(mse))
	expect_equal(fData(mse)$A.mean, rowMeans(mse[,g=="A"]))
	expect_equal(fData(mse)$B.mean, rowMeans(mse[,g=="B"]))
	expect_equal(fData(mse)$C.mean, rowMeans(mse[,g=="C"]))

	path2 <- CardinalIO::exampleImzMLFile("processed")
	mse2 <- readImzML(path2, memory=TRUE)

	mse2 <- summarizeFeatures(mse2)
	mse2 <- summarizeFeatures(mse2, groups=g)

	expect_equal(fData(mse2)$mean, rowMeans(mse2))
	expect_equal(fData(mse2)$A.mean, rowMeans(mse2[,g=="A"]))
	expect_equal(fData(mse2)$B.mean, rowMeans(mse2[,g=="B"]))
	expect_equal(fData(mse2)$C.mean, rowMeans(mse2[,g=="C"]))

})

test_that("summarizePixels", {

	register(SerialParam())

	path <- CardinalIO::exampleImzMLFile("continuous")
	mse <- readImzML(path, memory=TRUE)
	g <- makeFactor(light=mz(mse) < 400, heavy=mz(mse) >= 400)

	mse <- summarizePixels(mse)
	mse <- summarizePixels(mse, "sum", groups=g)

	expect_equal(pData(mse)$tic, colSums(mse))
	expect_equivalent(pData(mse)$light.sum, colSums(mse[g=="light",]))
	expect_equivalent(pData(mse)$heavy.sum, colSums(mse[g=="heavy",]))

	path2 <- CardinalIO::exampleImzMLFile("processed")
	mse2 <- readImzML(path2, memory=TRUE)

	mse2 <- summarizePixels(mse2)

	expect_equal(pData(mse2)$tic, colSums(mse2))

})
