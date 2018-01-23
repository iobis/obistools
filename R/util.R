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
  errors <- c()
  if (!"decimalLongitude" %in% names(data)) {
    errors <- c(errors, "Column decimalLongitude missing")
  } else if (!is.numeric(data$decimalLongitude)) {
    errors <- c(errors, "Column decimalLongitude is not numeric")
  }
  if (!"decimalLatitude" %in% names(data)) {
    errors <- c(errors, "Column decimalLatitude missing")
  } else if (!is.numeric(data$decimalLatitude)) {
    errors <- c(errors, "Column decimalLatitude is not numeric")
  }
  if(length(errors) > 0) {
    if(report) {
      return(data.frame(level = "error",  message = errors, stringsAsFactors = FALSE))
    } else {
      stop(paste(errors, collapse = ", "))
    }
  }
  return(NULL)
}

get_xy_clean_duplicates <- function(data) {
  check_lonlat(data, report = FALSE)
  if(NROW(data) > 0) {
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
  } else {
    list(uniquesp = data.frame(decimalLongitude = numeric(0), decimalLatitude = numeric(0)),
         isclean = NULL, duplicated_lookup = NULL)
  }
}

list_cache <- function() {
  list.files(rappdirs::user_cache_dir("obistools"), "call_", full.names = TRUE)
}

clear_cache <- function(age=36) {
  cachefiles <- list_cache()
  rmfiles <- cachefiles[difftime(Sys.time(), file.info(cachefiles)[,"mtime"], units = "hours") > age]
  unlink(rmfiles)
}

cache_call <- function(key, expr) {
  cache_dir <- rappdirs::user_cache_dir("obistools")
  cachefile <- file.path(cache_dir, paste0("call_", digest::digest(key)))
  if(file.exists(cachefile) && difftime(Sys.time(), file.info(cachefile)[,"mtime"], units = "hours") < 36) {
    return(readRDS(cachefile))
  } else {
    result <- eval(expr)
    if(!dir.exists(cache_dir)) {
      dir.create(cache_dir, showWarnings = FALSE)
    }
    saveRDS(result, cachefile)
    return(result)
  }
}
