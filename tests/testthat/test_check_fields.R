library(obistools)
context("check fields")

test_data <- data.frame(
  occurrenceID = c("1", "2", "3"),
  scientificName = c("Abra alba", NA, ""),
  locality = c("North Sea", "English Channel", "Flemish Banks"),
  minimumDepthInMeters = c("10", "", "5")
)

test_that("check_fields detects missing or empty required and recommended fields", {

  # required terms

  errors <- check_fields(test_data)
  expect_true(nrow(errors) == 8)

  # recommended terms

  errors <- check_fields(test_data, level = "warning")
  expect_true(nrow(errors) == 10)

})
