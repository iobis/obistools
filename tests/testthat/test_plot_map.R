library(testthat)

context("plotmap")

test_that("plot_map throws no errors", {
  expect_silent(plot_map(abra, zoom = TRUE))
  expect_silent(plot_map(abra, zoom = FALSE))
})

test_that("plot_map_leaflet throws no errors", {
  expect_silent(plot_map_leaflet(abra))
  expect_silent(plot_map_leaflet(abra, popup = "datasetID"))
})

