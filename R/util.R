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

get_xy_clean_duplicates <- function(data) {
  sp <- data %>% select(decimalLongitude, decimalLatitude)
  # Only lookup values for valid coordinates
  isclean <- complete.cases(sp) &
    sapply(sp$decimalLongitude, function(x) is.numeric(x)) &
    sapply(sp$decimalLatitude, function(x) is.numeric(x)) &
    !is.na(sp$decimalLongitude) & !is.na(sp$decimalLatitude) &
    sp$decimalLongitude >= -180.0 & sp$decimalLongitude <= 180.0 &
    sp$decimalLatitude >= -90.0 & sp$decimalLatitude <= 90.0
  cleansp <- sp[isclean,,drop=FALSE]
  if(NROW(cleansp) == 0) {
    output <- data.frame(row.names=1:NROW(sp))
    if(!asdataframe) {
      # Create a list with only NULL
      output <- list()
      output[[NROW(sp)+1]] <- NA
      output[[NROW(sp)+1]] <- NULL
    }
    return(output)
  }
  # Only lookup values for unique coordinates
  uniquesp <- unique(cleansp)
  mapping_unique <- merge(cbind(cleansp, clean_id=1:nrow(cleansp)),
                          cbind(uniquesp, unique_id=1:nrow(uniquesp)))
  duplicated_lookup <- mapping_unique[order(mapping_unique$clean_id),"unique_id"]
  list(uniquesp=uniquesp, isclean=isclean, duplicated_lookup=duplicated_lookup)
}
