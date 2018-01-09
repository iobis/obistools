library(testthat)

context("map_fields")

test_that("map_fields throws no errors", {
  df <- map_fields(data.frame(x=1:3, y=4:6),
                   list(decimalLongitude="x", decimalLatitude="y"))
  expect_true(all(c("decimalLongitude", "decimalLatitude") %in% names(df)))
  expect_equal(ncol(df), 2)
})
