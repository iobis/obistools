library(obistools)
context("check depth")


test_that("check_depth detects invalid or impossible depth values", {
  # Test cases
  # empty dataframe
  # Min D > Max D
  # Min D | Max D missing
  # Min D | Max D empty
  # Min D | Max D not numeric and not ''
  # Min D | Max D > bathy (and check depthmargin)
  # Min D | Max D < 0 & shoredist > 0 (and check shoremargin)
  # report: TRUE/FALSE
  # -> + check the above for on land points
  t1 <- data.frame(
    decimalLongitude=c(0),
    decimalLatitude=c(0),
    minimumDepthInMeters = c("4936", "4938", "4935", "-20"),
    maximumDepthInMeters = c("4936", "4937", "5000", "-10")
  )
  d1 <- check_depth(t1, depthmargin = 0, shoremargin = NA, report = FALSE)
  expect_equal(2, nrow(d1))
  expect_equal(c("4938", "5000"), as.character(d1$minimumDepthInMeters))
  r1 <- check_depth(t1, depthmargin = 0, shoremargin = NA, report = TRUE)
  expect_equal(5, nrow(r1))
  expect_equal(3, sum(grepl("depth margin", r1$message)))
  expect_equal(2, sum(grepl("greater than maximum", r1$message)))

  r2 <- check_depth(t1, depthmargin = 0, shoremargin = 1e6, report = TRUE)
  expect_equal(r1, r2)
  r3 <- check_depth(t1, depthmargin = 0, shoremargin = 0, report = TRUE)
  expect_equal(7, nrow(r3))
  expect_equal(3, sum(grepl("depth margin", r3$message)))
  expect_equal(2, sum(grepl("greater than maximum", r3$message)))
  expect_equal(2, sum(grepl("negative", r3$message)))


  t2 <- data.frame(decimalLongitude=c(0), decimalLatitude=c(0), minimumDepthInMeters=c("10"))
  check_depth(t2, depthmargin = 0, shoremargin = 0, report = FALSE)
  t3 <- data.frame(decimalLongitude=c(0), decimalLatitude=c(0), minimumDepthInMeters=c("10"))
  check_depth(t3, depthmargin = 0, shoremargin = 0, report = FALSE)
  t4 <- data.frame(decimalLongitude=c(0), decimalLatitude=c(0), minimumDepthInMeters=c(""), maximumDepthInMeters=c(""))
  check_depth(t4, depthmargin = 0, shoremargin = 0, report = FALSE)
  t5 <- data.frame(decimalLongitude=c(0), decimalLatitude=c(0), minimumDepthInMeters=c("10"), maximumDepthInMeters=c(""))
  check_depth(t5, depthmargin = 0, shoremargin = 0, report = FALSE)
})
