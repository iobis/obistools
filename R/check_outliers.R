
outliers_qc_values <- function(aphiaid) {
  cache_call(paste0("outliers_qc_values_", aphiaid), {
    tx <- robis::taxon(aphiaid=aphiaid)
    response <- httr::GET(paste0("http://api.iobis.org/taxon/", tx$valid_id, "/qc") )
    httr::content(response)
  })
}

# check_outliers <- function(data, report = TRUE) {
#   # Required fields for this:
#   # scientificNameID
#   # decimalLongitude
#   # decimalLatitude
#
#   # THEN parse the lsid:
#   # urn:lsid:marinespecies.org:taxname:23109
#
#   # THEN
#   # tx <- robis::taxon(aphiaid=23109)
#   # response <- httr::GET(paste0("http://api.iobis.org/taxon/", tx$valid_id, "/qc") )
#   # httr::content(response)
# }
#
#
# plot_outliers <- function(data) {
#
# }


