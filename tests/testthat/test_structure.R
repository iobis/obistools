library(testthat)

get_event <- function() {
  data.frame(
    eventID = c("cruise_1", "station_1", "station_2", "sample_1", "sample_2", "sample_3", "sample_4", "subsample_1", "subsample_2"),
    parentEventID = c(NA, "cruise_1", "cruise_1", "station_1", "station_1", "station_2", "station_2", "sample_3", "sample_3"),
    eventDate = c(NA, NA, NA, "2017-01-01", "2017-01-02", "2017-01-03", "2017-01-04", NA, NA),
    decimalLongitude = c(NA, 2.9, 4.7, NA, NA, NA, NA, NA, NA),
    decimalLatitude = c(NA, 54.1, 55.8, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE)
}

get_occurrence <- function() {
  data.frame(
    occurrenceID = 1:8,
    eventID = c("sample_1", "sample_1", "sample_2", "sample_2", "sample_3", "sample_4", "subsample_1", "subsample_1"),
    scientificName = c("Abra alba", "Lanice conchilega", "Pectinaria koreni", "Nephtys hombergii", "Pectinaria koreni", "Amphiura filiformis", "Desmolaimus zeelandicus", "Aponema torosa"),
    stringsAsFactors = FALSE)
}

test_that("treeStructure works", {
  ts <- treeStructure(get_event(), get_occurrence())
  expect_equal(ts$height, 6)
})

test_that("exportTree works", {
  ts <- treeStructure(get_event(), get_occurrence())
  f <- tempfile("treestructure", fileext = ".html")
  on.exit(file.remove(f))
  exportTree(ts, f)
  expect_true(file.exists(f))
})
