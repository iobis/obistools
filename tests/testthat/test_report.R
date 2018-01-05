library(testthat)

test_that("abra report works", {
  f <- report(abra, view = FALSE)
  expect_true(file.exists(f))
  expect_gt(file.size(f), 10000)
})

test_that("Testing several issues related to reporting and QC in general for large files", {
  testthat::skip()

  library(readr)
  library(digest)
  FED_Rockfish_Event_0ce4_4095_ea03 <- read_csv("https://www.sciencebase.gov/catalog/file/get/59417e4fe4b0764e6c64a5cf?f=__disk__f5%2Fe8%2Ffa%2Ff5e8fa79a077338d6ecb994359353f49003768c6")
  FED_Rockfish_Event_0ce4_4095_ea03 <- FED_Rockfish_Event_0ce4_4095_ea03[-1,]
  FED_Rockfish_Occurrence_f448_b903_e664 <- read_csv("https://www.sciencebase.gov/catalog/file/get/59417e4fe4b0764e6c64a5cf?f=__disk__d4%2Fb7%2Fdc%2Fd4b7dcef5125d43784d4c54e9515ea1395b96be0")
  FED_Rockfish_Occurrence_f448_b903_e664 <- FED_Rockfish_Occurrence_f448_b903_e664[-1,]
  FED_Rockfish_Occurrence_f448_b903_e664 <- FED_Rockfish_Occurrence_f448_b903_e664[-1:-11]


  # Make a few changes to the class of data and values for occurrenceStatus, remove occurrences where individualCount = NA
  # FED_Rockfish_Event_0ce4_4095_ea03$eventDate <- FED_Rockfish_Event_0ce4_4095_ea03$time
  FED_Rockfish_Event_0ce4_4095_ea03$decimalLatitude <- FED_Rockfish_Event_0ce4_4095_ea03$latitude
  FED_Rockfish_Event_0ce4_4095_ea03$decimalLongitude <- FED_Rockfish_Event_0ce4_4095_ea03$longitude
  # FED_Rockfish_Event_0ce4_4095_ea03$decimalLatitude <- as.numeric(FED_Rockfish_Event_0ce4_4095_ea03$latitude)
  # FED_Rockfish_Event_0ce4_4095_ea03$decimalLongitude <- as.numeric(FED_Rockfish_Event_0ce4_4095_ea03$longitude)

  # FED_Rockfish_Occurrence_f448_b903_e664$occurrenceStatus <- ifelse(FED_Rockfish_Occurrence_f448_b903_e664$individualCount > 0, "present", "absent")
  # FED_Rockfish_Occurrence_f448_b903_e664 <- FED_Rockfish_Occurrence_f448_b903_e664[which(!is.na(FED_Rockfish_Occurrence_f448_b903_e664$individualCount)),]

  # Check data using OBIS tools
  fullRockfish <- merge(FED_Rockfish_Event_0ce4_4095_ea03, FED_Rockfish_Occurrence_f448_b903_e664, by = "eventID", all.x = T, all.y = T)
  # check_eventdate(FED_Rockfish_Event_0ce4_4095_ea03)
  check_fields(fullRockfish)
  report(fullRockfish)
  # **********************************************************************************
  # TODO CHECK BELOW CODE WHEN decimalLongitude and/or decimalLatitude are not numeric
  # **********************************************************************************
  check_onland(FED_Rockfish_Event_0ce4_4095_ea03)
  check_depth(fullRockfish)

  write.table(FED_Rockfish_Event_0ce4_4095_ea03, file="RockfishRecruitmentAndEcosystemAssessmentSurveyCatchData_event.csv", sep = "|", dec = ".", qmethod = "double",
              col.names = TRUE, row.names=FALSE, fileEncoding="UTF-8", quote=TRUE)
  write.table(FED_Rockfish_Occurrence_f448_b903_e664, file="RockfishRecruitmentAndEcosystemAssessmentSurveyCatchData_occurrence.csv", sep = "|", dec = ".", qmethod = "double",
              col.names = TRUE, row.names=FALSE, fileEncoding="UTF-8", quote=TRUE)
})
