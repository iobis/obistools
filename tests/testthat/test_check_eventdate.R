library(obistools)

context("check eventDate")

data_nodate <- data.frame(
  scientificName = c("Abra alba", "Lanice conchilega"),
  stringsAsFactors = FALSE
)

data_goodformats <- data.frame(
  eventDate = c(
    "2016",
    "2016-01",
    "2016-01-02",
    "2016-01-02 13:00",
    "2016-01-02T13:00",
    "2016-01-02 13:00:00/2016-01-02 14:00:00",
    "2016-01-02 13:00:00/14:00:00"
  ),
  stringsAsFactors = FALSE
)

data_badformats <- data.frame(
  eventDate = c(
    "2016/01/02",
    "2016-01-02 13h00"
  ),
  stringsAsFactors = FALSE
)

test_that("", {

  results <- check_eventdate(data_nodate)
  expect_true(nrow(results) == 1)

  results <- check_eventdate(data_goodformats)
  expect_true(nrow(results) == 0)

  results <- check_eventdate(data_badformats)
  expect_true(nrow(results) == nrow(data_badformats))

})
