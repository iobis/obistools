library(testthat)
context("calculate_centroid")

get_test_wkt <- function() {
  list(wkt_point = "POINT (-64.02832 26.39187)",
       wkt_multipoint = "MULTIPOINT (-64.02832 26.39187, -65.961914 26.627818)",
       wkt_line = "LINESTRING (-73.081055 28.265682, -63.544922 29.61167, -59.72168 26.627818)",
       wkt_multiline = "MULTILINESTRING ((-73.081055 28.265682, -63.544922 29.61167, -59.72168 26.627818), (-68.994141 23.604262, -65.170898 23.926013))",
       wkt_polygon = "POLYGON ((-64.8 32.3, -65.5 18.3, -80.3 25.2, -64.8 32.3))",
       wkt_multipolygon = "MULTIPOLYGON (((-64.8 32.3, -65.5 18.3, -80.3 25.2, -64.8 32.3)), ((-78.662109 29.573457, -78.662109 31.316101, -75.410156 31.316101, -75.410156 29.573457, -78.662109 29.573457)))",
       multiple_wkt_point = c("POINT (-69.125977 29.382175)", "POINT (-55.283203 26.824071)", "POINT (-64.599609 24.327077)", "POINT (-74.135742 24.926295)", "POINT (-62.929688 21.657428)"),
       multiple_wkt_polygon = c("POLYGON ((-64.8 32.3, -65.5 18.3, -80.3 25.2, -64.8 32.3))", "POLYGON ((-78.662109 29.573457, -78.662109 31.316101, -75.410156 31.316101, -75.410156 29.573457, -78.662109 29.573457))"))
}

test_that("calculate_centroid for multiple common WKT formats works", {
  d <- get_test_wkt()
  for (n in names(d)) {
    centr <- calculate_centroid(d[[n]])
    expect_equal(nrow(centr), length(d[[n]]))
    expect_equal(colnames(centr), c("decimalLongitude", "decimalLatitude", "coordinateUncertaintyInMeters"))
  }
})

test_that("calculate_centroid missing wkt works", {
  expect_equal(NROW(calculate_centroid(NULL)), 0)
})

test_that("calculate_centroid simple wkt point works", {
  centr <- calculate_centroid("POINT (0 0)")
  expect_equal(centr[1,1], 0)
  expect_equal(centr[1,2], 0)
})

test_that("calculate_centroid simple wkt linestring works", {
  centr <- calculate_centroid("LINESTRING (0 -1, 0 0, 0 1)")
  expect_equal(centr[1,1], 0)
  expect_equal(centr[1,2], 0)
})

test_that("calculate_centroid simple wkt linestring works", {
  centr <- calculate_centroid("LINESTRING (-1 -1, 0 -1, 0 1, 1 1)")
  expect_equal(centr[1,1], 0)
  expect_equal(centr[1,2], 0)
})

test_that("calculate_centroid simple wkt polygon works", {
  centr <- calculate_centroid("POLYGON ((-1 -1, -1 1, 1 1, 1 -1, -1 -1))")
  expect_equal(centr[1,1], 0)
  expect_equal(centr[1,2], 0)
})

test_that("calculate_centroid accross dateline works", {
  centr <- calculate_centroid("POLYGON ((179 -1, 179 1, -179 1, -179 -1, 179 -1))")
  expect_equal(abs(centr[1,1]), 180)
  expect_equal(centr[1,2], 0)
})
