library(testthat)
context("check_onland")

check_skip <- function() {
  skip_on_cran()
}

test_data <- function(x=c(1,2,3), y=c(51,52,53)) {
  check_skip()
  data.frame(decimalLongitude=x, decimalLatitude=y)
}

test_that("check_onland offline parameter works", {
  data <- test_data(x=c(2.922825, 2.918780), y=c(51.236716, 51.237912))
  df <- check_onland(data, offline=F)
  expect_equal(nrow(df), 2)
  df <- check_onland(data, offline=T)
  expect_equal(nrow(df), 1)
})

test_that("check_onland buffer parameter works", {
  data <- test_data(x=c(2.922825, 2.918780), y=c(51.236716, 51.237912))
  df <- check_onland(data, offline=FALSE)
  expect_equal(nrow(df), 2)
  df <- check_onland(data, buffer=100, offline=FALSE)
  expect_equal(nrow(df), 1)
  df <- check_onland(data, buffer=1000, offline=FALSE)
  expect_equal(nrow(df), 0)
})

test_that("check_onland all on land works", {
  data <- test_data(x=c(20, 30), y=c(0, 0))
  df <- check_onland(data, offline=F)
  expect_equal(nrow(df), 2)
  df <- check_onland(data, offline=T)
  expect_equal(nrow(df), 2)
})

test_that("check_onland buffer parameter works", {
  data <- test_data(x=c(2.922825, 2.918780), y=c(51.236716, 51.237912))
  df <- check_onland(data, buffer=0, report=TRUE)
  expect_equal(nrow(df), 2)
  df <- check_onland(data, buffer=100, report=TRUE)
  expect_equal(nrow(df), 1)
  df <- check_onland(data, buffer=1000, report=TRUE)
  expect_equal(nrow(df), 0)
})
