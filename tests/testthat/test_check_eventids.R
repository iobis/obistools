library(obistools)
context("check eventIDs")

test_data_1 <- data.frame(
  eventID = c("a", "b"),
  stringsAsFactors = FALSE
)

test_data_2 <- data.frame(
  parentEventID = c("a", "b"),
  stringsAsFactors = FALSE
)

test_data_3 <- data.frame(
  eventID = c("a", "b", "c", "d", "e", "f"),
  parentEventID = c("", "", "a", "a", "bb", "b"),
  stringsAsFactors = FALSE
)

test_data_4 <- data.frame(
  eventID = c("a", "b", "b", "c"),
  parentEventID = "",
  stringsAsFactors = FALSE
)

test_that("check_eventids detects missing columns", {

  results <- check_eventids(test_data_1)
  expect_true(nrow(results) == 1)

  results <- check_eventids(test_data_2)
  expect_true(nrow(results) == 1)

})

test_that("check_eventids detects missing eventIDs", {

  results <- check_eventids(test_data_3)
  expect_true(nrow(results) == 1)
  expect_true(5 %in% results$row)

})

test_that("check_eventids detects duplicate eventIDs", {

  results <- check_eventids(test_data_4)
  expect_true(nrow(results) == 1)
  expect_true(3 %in% results$row)

})

test_that("check_extension_eventids works", {

  event <- data.frame(eventID = c("a", "b", "b", "c"), stringsAsFactors = FALSE)
  extension <- data.frame(xeventID = c("a", "b", "b", "d", "e"), stringsAsFactors = FALSE)
  df <- check_extension_eventids(event, extension, "xeventID")
  expect_equal(nrow(df), 2)
  expect_true(all(c(4,5) %in% df$row))

  df <- check_extension_eventids(event[NULL, , drop=FALSE], extension[NULL, , drop=FALSE], "xeventID")
  expect_equal(nrow(df), 0)

})
