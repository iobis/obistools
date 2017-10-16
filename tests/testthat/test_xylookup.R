library(testthat)
context("xylookup")

check_skip <- function() {
  skip_on_cran()
}

test_data <- function(x=c(1,2,3), y=c(51,52,53)) {
  check_skip()
  data.frame(decimalLongitude=x, decimalLatitude=y)
}

test_that("lookup_xy returns correct data", {
  results <- lookup_xy(test_data(), asdataframe = FALSE)
  expect_equal(length(results), 3)
  r1 <- results[[1]]
  expect_equal(sort(names(r1)), c("grids", "shoredistance"))
  expect_true("bathymetry" %in% names(r1$grids))
})

test_that("lookup_xy results filtering works", {
  results <- lookup_xy(test_data(), areas = TRUE)
  expect_equal(nrow(results), 3)
  expect_true(all(c("shoredistance", "bathymetry", "final_grid5") %in% colnames(results)))
  results <- lookup_xy(test_data(), areas = FALSE, grids = FALSE, shoredistance = TRUE)
  expect_equal(results[1,,drop=F]$shoredistance, 1612)
  expect_false(any(c("bathymetry", "final_grid5") %in% colnames(results)))
  results <- lookup_xy(test_data(), areas = FALSE, grids = TRUE, shoredistance = FALSE)
  expect_false(any(c("shoredistance", "final_grid5") %in% colnames(results)))
  expect_equal(results[1,,drop=F]$bathymetry, 2)
})

test_that("lookup_xy empty areas works", {
  results <- lookup_xy(test_data(x=90,y=60), areas = TRUE, shoredistance = FALSE, grids = FALSE)
  expect_equal(nrow(results), 1)
  expect_equal(ncol(results), 0)
})

test_that("lookup_xy duplicate coordinates works", {
  results <- lookup_xy(test_data(x=c(90,90,0,1,2,1),y=c(60,60,0,4,3,4)), asdataframe = FALSE)
  expect_equal(length(results), 6)
  expect_equal(results[[1]],results[[2]])
  expect_equal(results[[4]],results[[6]])

  results <- lookup_xy(test_data(x=c(90,90,0,1,2,1),y=c(60,60,0,4,3,4)), asdataframe = TRUE)
  expect_equal(nrow(results), 6)
  expect_equal(as.list(results[1,]),as.list(results[2,]))
  expect_equal(as.list(results[4,]),as.list(results[6,]))
})

test_that("lookup_xy mix of valid and invalid coordinates works", {
  data <- test_data(x=c(90,"90",NA,-181,2,181,0),y=c(-91,60,0,4,91,4,0))
  f <- function(asdataframe) {
    lookup_xy(data, asdataframe = asdataframe)
  }
  expect_warning({results <- f(F)})
  expect_equal(length(results), 7)
  expect_true(all(sapply(results, is.null)))

  expect_warning({results <- f(T)})
  expect_equal(nrow(results), 7)

  data <- test_data(x=c(90,NA,-181,2,181,0),y=c(-91,0,4,91,4,0))
  results <- lookup_xy(data, asdataframe = FALSE)
  expect_equal(length(results), 6)
  expect_equal(results[[1]], NULL)
  expect_equal(sort(names(results[[6]])), c("grids", "shoredistance"))

  results <- lookup_xy(data, asdataframe = TRUE)
  expect_equal(nrow(results), 6)
  expect_equal(sum(is.na(results$shoredistance)), 5)
  expect_false(is.na(results$shoredistance[6]))
})

# test_that("lookup_xy long list of coordinates works", {
#   skip_on_travis()
#   set.seed(42)
#   data <- test_data(x=runif(10000, -180, 180),y=runif(10000, -90, 90))
#   data <- data[rep(1:10000, 50),]
#   results <- lookup_xy(data, asdataframe = FALSE)
#   expect_equal(length(results), 500000)
#
#   system.time({results <- lookup_xy(data, asdataframe = TRUE)})
#   expect_equal(nrow(results), 500000)
# })
