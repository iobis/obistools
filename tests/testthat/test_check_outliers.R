library(obistools)
context("check outliers")


test_that("check_outliers_datasets identifies outliers", {
  data <- data.frame(decimalLongitude=170, decimalLatitude=c(50, 1:25))
  rp <- check_outliers_dataset(data, report = TRUE)
  expect_gte(nrow(rp), 1)
  d <- check_outliers_dataset(data, report = FALSE)
  expect_equal(d, data[1,])
})

test_that("check_outliers_species identifies outliers", {
  data <- data_frame(decimalLongitude=170, decimalLatitude=c(50, 1:25), scientificNameID="urn:lsid:marinespecies.org:taxname:23109")
  rp <- check_outliers_species(data, report = TRUE)
  expect_gte(nrow(rp), 1)
  d <- check_outliers_species(data, report = FALSE)
  expect_equal(d, data[unique(na.omit(rp$row)),])
})

test_that("check_outliers_species works for abra", {
  d <- check_outliers_species(abra)
  expect_gte(nrow(d), 500)
})
