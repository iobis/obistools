library(obistools)
context("check depth")


test_that("check_depth detects invalid or impossible depth values", {
  # Overview of all test cases:
  # empty dataframe
  # Min D > Max D
  # Min D | Max D missing
  # Min D | Max D empty
  # Min D | Max D not numeric and not ''
  # Min D | Max D > bathy (and check depthmargin)
  # Min D | Max D < 0 & shoredist > 0 (and check shoremargin)
  # report: TRUE/FALSE

  t1 <- data.frame(decimalLongitude=0, decimalLatitude=0,
    minimumDepthInMeters = c("4936", "4938", "4935", "-20"),
    maximumDepthInMeters = c("4936", "4937", "5000", "-10"))
  d1 <- check_depth(t1, depthmargin = 0, shoremargin = NA, report = FALSE)
  expect_equal(2, nrow(d1))
  expect_equal(c("4938", "4935"), as.character(d1$minimumDepthInMeters))
  r <- check_depth(t1, depthmargin = 0, shoremargin = NA, report = TRUE)
  expect_equal(5, nrow(r))
  expect_equal(3, sum(grepl("depth.*?margin", r$message)))
  expect_equal(2, sum(grepl("greater than maximum", r$message)))

  r2 <- check_depth(t1, depthmargin = 0, shoremargin = 1e6, report = TRUE)
  expect_equal(r, r2)

  r <- check_depth(t1, depthmargin = 1000, shoremargin = NA, report = TRUE)
  expect_equal(2, nrow(r))
  expect_equal(0, sum(grepl("depth.*?margin", r$message)))
  expect_equal(2, sum(grepl("greater than maximum", r$message)))

  r <- check_depth(t1, depthmargin = 0, shoremargin = 0, report = TRUE)
  expect_equal(7, nrow(r))
  expect_equal(3, sum(grepl("depth.*?margin", r$message)))
  expect_equal(2, sum(grepl("greater than maximum", r$message)))
  expect_equal(2, sum(grepl("shoredistance.*?margin", r$message)))
  expect_equal(2, sum(grepl("negative", r$message)))

  # missing column
  t <- data.frame(decimalLongitude=c(0), decimalLatitude=c(0), minimumDepthInMeters=c("10"))
  d <- check_depth(t, depthmargin = 0, shoremargin = 0, report = FALSE)
  expect_equal(0, nrow(d))
  r <- check_depth(t, depthmargin = 0, shoremargin = 0, report = TRUE)
  expect_equal(1, sum(grepl("missing", r$message)))

  # missing column + an error
  t <- data.frame(decimalLongitude=c(0), decimalLatitude=c(0), minimumDepthInMeters=c("10", "10000"))
  d <- check_depth(t, depthmargin = 0, shoremargin = 0, report = FALSE)
  expect_equal(1, nrow(d))
  r <- check_depth(t, depthmargin = 0, shoremargin = 0, report = TRUE)
  expect_equal(1, sum(grepl("missing", r$message)))
  expect_equal(1, sum(grepl("depth.*?margin", r$message)))
  expect_equal(2, nrow(r))

  t <- data.frame(decimalLongitude=c(0), decimalLatitude=c(0), minimumDepthInMeters=c("", "", ""), maximumDepthInMeters="4")
  r <- check_depth(t, depthmargin = 0, shoremargin = 0, report = TRUE)
  expect_equal(1, sum(grepl("empty", r$message)))
  t$minimumDepthInMeters <- c("", "a", "1")
  expect_warning({
    r <- check_depth(t, depthmargin = 0, shoremargin = 0, report = TRUE)
    expect_equal(1, sum(grepl("not numeric", r$message)))
  }, "NAs")
})

test_that("Issue 42", {
  skip_if_not_installed("robis")
  pol <- robis::occurrence("Polychaeta", geometry = "POLYGON ((6.50391 54.59753, 6.45996 53.14677, 8.26172 53.17312, 8.08594 54.54658, 6.50391 54.59753))")
  problems <- check_depth(pol, report=FALSE)
  testthat::expect_gt(nrow(problems), 5)
  problems <- check_depth(pol, report=TRUE)
  testthat::expect_gt(nrow(problems), 5)

  problems_margin10 <- check_depth(pol, depthmargin=10, report=TRUE)
  testthat::expect_lt(nrow(problems_margin10), nrow(problems))
})

test_that("External rasters are used", {
  x <- raster::raster(nrow=10, ncol=10,
                      xmn=-5, xmx=5, ymn=-5, ymx=5,
                      crs="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0",
                      resolution=1)
  set.seed(42)
  raster::values(x) <- runif(100, min = 0, max = 1000)

  t1 <- data.frame(decimalLongitude=0, decimalLatitude=0,
                   minimumDepthInMeters = c("4936", "4938", "4935", "-20"),
                   maximumDepthInMeters = c("4936", "4937", "5000", "-10"))
  d1 <- check_depth(t1, depthmargin = 0, shoremargin = NA, report = FALSE)

  d1 <- check_depth(t1, bathymetry=x, depthmargin = 0, shoremargin = NA, report = FALSE)

  fail("TODO FINISH TEST")
  fail("TODO Invalid / no raster provided")
  fail("TODO Coordinates outside raster: issue warning")
})

test_that("support for tibble", {
  skip_if_not_installed("dplyr")
  t1 <- data.frame(decimalLongitude=0, decimalLatitude=0,
                   minimumDepthInMeters = c("4936", "4938", "4935", "-20"),
                   maximumDepthInMeters = c("4936", "4937", "5000", "-10"))
  r1 <- check_depth(t1, depthmargin = 0, shoremargin = NA, report = TRUE)
  t2 <- dplyr::as_tibble(t1)
  r2 <- check_depth(t2, depthmargin = 0, shoremargin = NA, report = TRUE)
  expect_equal(r2, r1)
  expect_equal(nrow(r2), 5)
})

test_that("invalid x/y coordinates works", {
  fail("TODO finish this test")
  fail("TODO write the code to handle the case where no bathymetry was found => issue a warning")
})

test_that("document lookup_xy, check_depth, check_onland", {
  fail("readme lookup_xy")
  fail("readme check_depth")
  fail("readme check_onland")
})
