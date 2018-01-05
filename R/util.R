missing_fields <- function(data, fields) {
  missing <- !(fields %in% names(data))
  return(fields[missing])
}

missing_values <- function(data) {
  return(data %in% c(NA, ""))
}

#' Event Core fields.
#'
#' @return Event Core fields.
#' @export
event_fields <- function() {
  xml <- read_xml(system.file("", "event_core.xml", package = "obistools"))
  return(xml_attr(xml_children(xml), "name"))
}

#' Occurrence Core fields.
#'
#' @return Occurrence Core fields.
#' @export
occurrence_fields <- function() {
  xml <- read_xml(system.file("", "occurrence_core.xml", package = "obistools"))
  return(xml_attr(xml_children(xml), "name"))
}

check_lonlat <- function(data, report) {
  errors <- data.frame()
  if (!"decimalLongitude" %in% names(data)) {
    errors <- rbind(errors, data.frame(level = "error",  message = "Column decimalLongitude missing", stringsAsFactors = FALSE))
  }
  if (!"decimalLatitude" %in% names(data)) {
    errors <- rbind(errors, data.frame(level = "error",  message = "Column decimalLatitude missing", stringsAsFactors = FALSE))
  }
  if(NROW(errors) > 0 && !report) {
    stop(paste(errors$message, collapse = ", "))
  }
  return(errors)
}

get_xy_clean_duplicates <- function(data, asdataframe=TRUE) {
  stopifnot(NROW(data) > 0 & !is.null("No data provided"))
  sp <- data %>% select(decimalLongitude, decimalLatitude)
  # Only lookup values for valid coordinates
  isclean <- stats::complete.cases(sp) &
    sapply(sp$decimalLongitude, is.numeric) &
    sapply(sp$decimalLatitude, is.numeric) &
    !is.na(sp$decimalLongitude) & !is.na(sp$decimalLatitude) &
    sp$decimalLongitude >= -180.0 & sp$decimalLongitude <= 180.0 &
    sp$decimalLatitude >= -90.0 & sp$decimalLatitude <= 90.0
  cleansp <- sp[isclean,,drop=FALSE]
  # Only lookup values for unique coordinates
  uniquesp <- unique(cleansp)
  mapping_unique <- merge(cbind(cleansp, clean_id=seq_len(nrow(cleansp))),
                          cbind(uniquesp, unique_id=seq_len(nrow(uniquesp))))
  duplicated_lookup <- mapping_unique[order(mapping_unique$clean_id),"unique_id"]
  list(uniquesp=uniquesp, isclean=isclean, duplicated_lookup=duplicated_lookup)
}
