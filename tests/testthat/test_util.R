library(testthat)
context("util")

test_that("check lon lat works as expected", {
  x <- obistools:::check_lonlat(data.frame(), report = TRUE)
  expect_equal(2, nrow(x))
  expect_true(all(grepl("missing", x$message)))
  x <- obistools:::check_lonlat(data.frame(decimalLatitude = ""), report = TRUE)
  expect_equal(2, nrow(x))
  expect_true(all(grepl("(missing)|(numeric)", x$message)))
  x <- obistools:::check_lonlat(data.frame(decimalLatitude = 1), report = TRUE)
  expect_equal(1, nrow(x))
  expect_true(all(grepl("(missing)|(numeric)", x$message)))
  x <- obistools:::check_lonlat(data.frame(decimalLongitude = "", decimalLatitude = ""), report = TRUE)
  expect_equal(2, nrow(x))
  expect_true(all(grepl("numeric", x$message)))
  x <- obistools:::check_lonlat(data.frame(decimalLongitude = "", decimalLatitude = 1), report = TRUE)
  expect_equal(1, nrow(x))
  expect_true(all(grepl("numeric", x$message)))
  x <- obistools:::check_lonlat(data.frame(decimalLongitude = 1, decimalLatitude = 1), report = TRUE)
  expect_equal(0, NROW(x))
  expect_error(obistools:::check_lonlat(data.frame(), report = FALSE), "missing")
})

test_that("cache call works", {
  n <- 5
  set.seed(42)
  original <- obistools:::cache_call("random5", expression(runif(n)))
  set.seed(50)
  same <- obistools:::cache_call("random5", expression(runif(n)))
  set.seed(50)
  different <- obistools:::cache_call("random5diff", expression(runif(n)))
  set.seed(50)
  original2 <- obistools:::cache_call("random5", expression(runif(n, min = 0, max = 1) ))
  expect_equal(length(original), n)
  expect_equal(original, same)
  expect_false(any(original == different))
  expect_equal(original2, different)
  expect_gte(length(obistools:::list_cache()), 3)
  # only run on Travis as clearing the cache between the test runs is annoying
  if(identical(Sys.getenv("TRAVIS"), "true")) {
    obistools:::clear_cache(-1)
    expect_equal(length(obistools:::list_cache()), 0)
  }
})

test_that("get_xy_clean_duplicates works", {
  n <- 100
  set.seed(42)
  lots_duplicates <- data_frame(decimalLongitude=as.numeric(sample(1:10, n, replace=TRUE)), decimalLatitude=as.numeric(sample(1:10, n, replace=TRUE)))
  lots_duplicates[5,] <- c(NA,1.0)
  lots_duplicates[6,] <- c(2.0,NA)
  lots_duplicates[7,] <- c(NA,NA)
  xy <- obistools:::get_xy_clean_duplicates(lots_duplicates)

  replicate <- data_frame(decimalLongitude=rep(NA,n), decimalLatitude=rep(NA,n))
  replicate[xy$isclean,] <- xy$uniquesp[xy$duplicated_lookup,]
  replicate[!xy$isclean,] <- lots_duplicates[!xy$isclean,]
  expect_equal(lots_duplicates, replicate)
})
