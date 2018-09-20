library(testthat)

test_that("abra report works", {
  f <- report(abra, view = FALSE)
  expect_true(file.exists(f))
  expect_gt(file.size(f), 10000)
})

test_that("Testing several issues related to reporting and QC in general for large files", {
  testthat::skip("Skip very slow test related to very large files reporting")

  library(readr)
  library(digest)
  FED_Rockfish_Event_0ce4_4095_ea03 <- read_csv("https://www.sciencebase.gov/catalog/file/get/59417e4fe4b0764e6c64a5cf?f=__disk__f5%2Fe8%2Ffa%2Ff5e8fa79a077338d6ecb994359353f49003768c6")
  FED_Rockfish_Event_0ce4_4095_ea03 <- FED_Rockfish_Event_0ce4_4095_ea03[-1,]
  FED_Rockfish_Occurrence_f448_b903_e664 <- read_csv("https://www.sciencebase.gov/catalog/file/get/59417e4fe4b0764e6c64a5cf?f=__disk__d4%2Fb7%2Fdc%2Fd4b7dcef5125d43784d4c54e9515ea1395b96be0")
  FED_Rockfish_Occurrence_f448_b903_e664 <- FED_Rockfish_Occurrence_f448_b903_e664[-1,]
  FED_Rockfish_Occurrence_f448_b903_e664 <- FED_Rockfish_Occurrence_f448_b903_e664[-1:-11]


  # Make a few changes to the class of data and values for occurrenceStatus, remove occurrences where individualCount = NA
  # FED_Rockfish_Event_0ce4_4095_ea03$eventDate <- FED_Rockfish_Event_0ce4_4095_ea03$time
  check_onland(FED_Rockfish_Event_0ce4_4095_ea03)
  FED_Rockfish_Event_0ce4_4095_ea03$decimalLatitude <- FED_Rockfish_Event_0ce4_4095_ea03$latitude
  FED_Rockfish_Event_0ce4_4095_ea03$decimalLongitude <- FED_Rockfish_Event_0ce4_4095_ea03$longitude
  check_onland(FED_Rockfish_Event_0ce4_4095_ea03)


  # FED_Rockfish_Occurrence_f448_b903_e664$occurrenceStatus <- ifelse(FED_Rockfish_Occurrence_f448_b903_e664$individualCount > 0, "present", "absent")
  # FED_Rockfish_Occurrence_f448_b903_e664 <- FED_Rockfish_Occurrence_f448_b903_e664[which(!is.na(FED_Rockfish_Occurrence_f448_b903_e664$individualCount)),]

  # Check data using OBIS tools
  FED_Rockfish_Event_0ce4_4095_ea03$decimalLatitude <- as.numeric(FED_Rockfish_Event_0ce4_4095_ea03$latitude)
  FED_Rockfish_Event_0ce4_4095_ea03$decimalLongitude <- as.numeric(FED_Rockfish_Event_0ce4_4095_ea03$longitude)

  fullRockfish <- merge(FED_Rockfish_Event_0ce4_4095_ea03, FED_Rockfish_Occurrence_f448_b903_e664, by = "eventID", all.x = T, all.y = T)
  # check_eventdate(FED_Rockfish_Event_0ce4_4095_ea03)
  check_fields(fullRockfish)
  report(fullRockfish)

  check_onland(FED_Rockfish_Event_0ce4_4095_ea03)
  check_depth(fullRockfish)

  # write.table(FED_Rockfish_Event_0ce4_4095_ea03, file="RockfishRecruitmentAndEcosystemAssessmentSurveyCatchData_event.csv", sep = "|", dec = ".", qmethod = "double",
  #             col.names = TRUE, row.names=FALSE, fileEncoding="UTF-8", quote=TRUE)
  # write.table(FED_Rockfish_Occurrence_f448_b903_e664, file="RockfishRecruitmentAndEcosystemAssessmentSurveyCatchData_occurrence.csv", sep = "|", dec = ".", qmethod = "double",
  #             col.names = TRUE, row.names=FALSE, fileEncoding="UTF-8", quote=TRUE)
  # head(fullRockfish)
})

test_that('Deep sea', {
  skip("Skip deep sea file checking")
  library(openxlsx)
  library(obistools)
  path <- "/Users/samuel/Downloads/OBIS-ENV-DATA_BENEFICIAL_deepsea.xlsx"
  events <- read.xlsx(path, sheet = 1)
  occurrences <- read.xlsx(path, sheet = 2)
  emof <- read.xlsx(path, sheet = 3)

  issues <- check_eventids(events)
  View(issues)
  flat_events <- flatten_event(events)

  issues <- check_extension_eventids(events, occurrences)

  data <- flatten_occurrence(events, occurrences)
  report(data)




  download_all <- function(url) {
     data <- data.frame(stringsAsFactors = FALSE)
     v <- jsonlite::fromJSON(url)
     while(!is.null(v$odata.nextLink) && NROW(v$value) > 0) {
       v <- jsonlite::fromJSON(v$odata.nextLink)
       data <- rbind(data, v$value)
     }
     data
   }
  events <- download_all('http://testbed.ymparisto.fi/api/Pohjaelainrajapinta/1.0/odata/Event/')


})

test_that('issue with NA long/lat', {
  skip("Skip issue with NA long/lat")
  require(obistools)
  require(finch)

  dwca_cache$delete_all()
  out <- dwca_read('http://www.dassh.ac.uk/ipt/archive?r=emodnet_07_cefas_mcz_improved', read = TRUE)

  Event <- out$data[["event.txt"]]
  Event$parentEventID <- NA

  Occurrence <- out$data[["occurrence.txt"]]
  eMoF <- out$data[["extendedmeasurementorfact.txt"]]


  flat <- flatten_occurrence(Event, Occurrence)

  report(flat)
  # Quitting from lines 12-14 (report.Rmd)
  # Error in if (zero_range(range)) { : missing value where TRUE/FALSE needed
  #   In addition: Warning message:
  #     distinct() does not fully support columns of type `list`.
  #   List elements are compared by reference, see ?distinct for details.
  #   This affects the following columns:
  #     - `extra`
  #
  #   Volgende werkt wel
  #   report(flatten_occurrence(Event,Occurrence) %>% filter (!is.na(decimalLatitude), !is.na(decimalLongitude)) , view = FALSE)
})
