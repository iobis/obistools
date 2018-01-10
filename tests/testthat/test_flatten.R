library(testthat)
context("flatten")

test_that("flatten_event works", {
  event <- data.frame(
    eventID = c("cruise_1", "station_1", "station_2", "sample_1", "sample_2", "sample_3", "sample_4", "subsample_1", "subsample_2"),
    parentEventID = c(NA, "cruise_1", "cruise_1", "station_1", "station_1", "station_2", "station_2", "sample_3", "sample_3"),
    eventDate = c(NA, NA, NA, "2017-01-01", "2017-01-02", "2017-01-03", "2017-01-04", NA, NA),
    decimalLongitude = c(NA, 2.9, 4.7, NA, NA, NA, NA, NA, NA),
    decimalLatitude = c(NA, 54.1, 55.8, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )

  e <- flatten_event(event)
  expect_equal(nrow(e), 9)
  expect_equal(unlist(event[event$eventID == "station_1", c("decimalLongitude", "decimalLatitude")]),
               unlist(unique(e[!is.na(e$parentEventID) & e$parentEventID == "station_1", c("decimalLongitude", "decimalLatitude")])))
})


test_that("flatten_event catch event id errors", {
  event <- data.frame(eventID = c("a", "b", "c", "d", "e", "f"),
                      parentEventID = c("", "", "a", "a", "bb", "b"),
                      stringsAsFactors = FALSE)
  expect_error(flatten_event(event), "check_eventids")
})

test_that("flatten_event custom fields", {
  event <- data.frame(eventID = c("a", "b", "c", "d"),
                      parentEventID = c("", "", "a", "a"),
                      test_column1 = c(1:2, NA, NA),
                      test_column2 = c(1:2, NA, NA),
                      stringsAsFactors = FALSE)
  e <- flatten_event(event, fields = "test_column1")
  expect_equal(nrow(e), 4)
  expect_equal(e$test_column1, c(1,2,1,1))
  expect_equal(e$test_column2, c(1,2,NA,NA))
})

test_that("flatten_occurrence works", {
  event <- data.frame(
    eventID = c("cruise_1", "station_1", "station_2", "sample_1", "sample_2", "sample_3", "sample_4", "subsample_1", "subsample_2"),
    parentEventID = c(NA, "cruise_1", "cruise_1", "station_1", "station_1", "station_2", "station_2", "sample_3", "sample_3"),
    eventDate = c(NA, NA, NA, "2017-01-01", "2017-01-02", "2017-01-03", "2017-01-04", NA, NA),
    decimalLongitude = c(NA, 2.9, 4.7, NA, NA, NA, NA, NA, NA),
    decimalLatitude = c(NA, 54.1, 55.8, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  occurrence <- data.frame(
    eventID = c("sample_1", "sample_1", "sample_2", "sample_2", "sample_3", "sample_4", "subsample_1", "subsample_1"),
    scientificName = c("Abra alba", "Lanice conchilega", "Pectinaria koreni", "Nephtys hombergii", "Pectinaria koreni", "Amphiura filiformis", "Desmolaimus zeelandicus", "Aponema torosa"),
    stringsAsFactors = FALSE
  )
  f <- flatten_occurrence(event, occurrence)
  expect_equal(nrow(f), 8)
  expect_equal(f$eventID, occurrence$eventID)
  expect_equal(f$scientificName, occurrence$scientificName)
  expect_true(all(!is.na(f$eventDate)))
  expect_true(all(!is.na(f$decimalLongitude)))
  expect_true(all(!is.na(f$decimalLatitude)))
})
