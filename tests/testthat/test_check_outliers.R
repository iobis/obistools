library(obistools)
context("check outliers")


test_that("check_outliers_datasets identifies outliers", {
  data <- data.frame(decimalLongitude=170, decimalLatitude=1:25)
  check_outliers_dataset(data, report = TRUE)
  check_outliers_species(data, report = TRUE)
  #lookup_xy(data)

  data <- data.frame(decimalLongitude=170, decimalLatitude=1:25, scientificNameID="")
  check_outliers_dataset(data, report = TRUE)
  check_outliers_species(data, report = TRUE)
})
