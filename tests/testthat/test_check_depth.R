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
  expect_equal(3, sum(grepl("depth margin", r$message)))
  expect_equal(2, sum(grepl("greater than maximum", r$message)))

  r2 <- check_depth(t1, depthmargin = 0, shoremargin = 1e6, report = TRUE)
  expect_equal(r, r2)

  r <- check_depth(t1, depthmargin = 1000, shoremargin = NA, report = TRUE)
  expect_equal(2, nrow(r))
  expect_equal(0, sum(grepl("depth margin", r$message)))
  expect_equal(2, sum(grepl("greater than maximum", r$message)))

  r <- check_depth(t1, depthmargin = 0, shoremargin = 0, report = TRUE)
  expect_equal(7, nrow(r))
  expect_equal(3, sum(grepl("depth margin", r$message)))
  expect_equal(2, sum(grepl("greater than maximum", r$message)))
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
  expect_equal(1, sum(grepl("depth margin", r$message)))
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
