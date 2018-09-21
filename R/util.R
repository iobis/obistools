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
      return(data_frame(level = "error",  message = errors))
    } else {
      stop(paste(errors, collapse = ", "))
    }
  }
  return(NULL)
}


get_xy_clean <- function(data, returnisclean=FALSE) {
  check_lonlat(data, report = FALSE)
  sp <- data.frame(decimalLongitude = numeric(0), decimalLatitude = numeric(0))
  isclean <- NULL
  if(NROW(data) > 0) {
    sp <- data %>% select(decimalLongitude, decimalLatitude)
    # Only valid coordinates
    isclean <- stats::complete.cases(sp) &
      sapply(sp$decimalLongitude, is.numeric) &
      sapply(sp$decimalLatitude, is.numeric) &
      !is.na(sp$decimalLongitude) & !is.na(sp$decimalLatitude) &
      sp$decimalLongitude >= -180.0 & sp$decimalLongitude <= 180.0 &
      sp$decimalLatitude >= -90.0 & sp$decimalLatitude <= 90.0
  }
  cleansp <- sp[isclean,,drop=FALSE]
  if(returnisclean) {
    return(list(cleansp=cleansp, isclean=isclean))
  } else {
    return(cleansp)
  }
}

get_xy_clean_duplicates <- function(data) {
  clean <- get_xy_clean(data, returnisclean = TRUE)
  if(NROW(clean$cleansp) > 0) {
    # Only lookup values for unique coordinates
    key <- paste(clean$cleansp$decimalLongitude, clean$cleansp$decimalLatitude, sep='\r')
    notdup <- !duplicated(key)
    uniquesp <- clean$cleansp[notdup,]
    duplicated_lookup <- match(key, key[notdup])
    list(uniquesp=uniquesp, isclean=clean$isclean, duplicated_lookup=duplicated_lookup)
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
  rmfiles
}

cache_call <- function(key, expr, env = NULL) {
  stopifnot(is.expression(expr))
  if(is.null(env)) {
    env = parent.frame()
  }
  cache_dir <- rappdirs::user_cache_dir("obistools")
  cachefile <- file.path(cache_dir, paste0("call_", digest::digest(list(key=key, expr=expr)), ".rds"))
  if(file.exists(cachefile) && difftime(Sys.time(), file.info(cachefile)[,"mtime"], units = "hours") < 10) {
    return(readRDS(cachefile))
  } else {
    result <- eval(expr, envir = NULL, enclos = env)
    if(!dir.exists(cache_dir)) {
      dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
    }
    saveRDS(result, cachefile)
    return(result)
  }
}

service_call <- function(url, msg) {
  cache_call(key = paste(url, msg),
             expression({
               response <- httr::POST(url,
                                      httr::content_type("application/json"),
                                      httr::user_agent("obistools - https://github.com/iobis/obistools"),
                                      body=msg)

               # Parse result
               raw_content <- httr::content(response, as="raw")
               if(response$status_code != 200) {
                 if(is.list(raw_content) && all(c("title", "description") %in% names(raw_content))) {
                   stop(paste0(raw_content$title, ": ", raw_content$description))
                 }
                 stop(rawToChar(raw_content))
               }
               raw_content
             }))
}
