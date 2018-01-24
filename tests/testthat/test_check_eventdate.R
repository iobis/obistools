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

test_that("good and bad eventDate work", {

  results <- check_eventdate(data_nodate)
  expect_equal(nrow(results), 1)

  results <- check_eventdate(data_goodformats)
  expect_equal(nrow(results), 0)

  results <- check_eventdate(data_badformats)
  expect_equal(nrow(results), nrow(data_badformats))

})

test_that("date columns are ok", {
  data <- data.frame(eventDate = c(as.Date("2006-01-12"), as.Date("2006-01-13"), NA))
  results <- check_eventdate(data)
  expect_equal(nrow(results), 1)
  expect_equal(results$row, 3)
})
