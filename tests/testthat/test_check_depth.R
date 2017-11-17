library(obistools)
context("check depth")

test_data <- data.frame(
  decimalLongitude=c(0),
  decimalLatitude=c(0),
  minimumDepthInMeters = c("10", "", "5"),
  maximumDepthInMeters = c("10", "", "5")
)

test_that("check_depth detects invalid or impossible depth values", {

  # TEST CASES TO TEST
  # Min D > Max D
  # Min D / Max D missing
  # Min D / Max D empty
  # Min D / Max D not numeric and not ''
  # Min D / Max D > bathy (and check depthmargin)
  # Min D / Max D < 0 & shoredist > 0 (and check shoremargin)

})
