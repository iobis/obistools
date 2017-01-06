library(obistools)
context("match taxa")

test_names <- c("Abra alva", "Buccinum fusiforme", "Buccinum fusiforme", "Buccinum fusiforme", "ljkf hlqsdkf")

test_that("match_taxa works as expected", {

  results <- match_taxa(test_names, ask = FALSE)
  expect_true(nrow(results) == length(test_names))
  expect_true(sum(!is.na(results$scientificNameID)) == 1)

})
