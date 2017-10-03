#' Lookup spatial data for a set of points.
#'
#' @usage lookup_xy(data, shoredistance=TRUE, grids=TRUE, areas=FALSE,
#'   verbose=FALSE)
#'
#' @param data The data frame with columns decimalLongitude and decimalLatitude.
#' @param shoredistance Indicate whether the shoredistance should be returned
#'   (default \code{TRUE}).
#' @param grids Indictate whether the grid values such as temperature and
#'   bathymetry should be returned (default \code{TRUE})
#' @param areas Indictate whether the area values should be returned (default
#'   \code{FALSE}).
#' @param asdataframe Indicate whether a dataframe or a list should be returned
#'   (default \code{TRUE}).
#'
#' @return Data frame or list with the values for the different requested
#'   fields.
#'
#' @details Data is returned in the same order as the requested data as a list,
#'   with for each list item the requested values. For invalid coordinates
#'   \code{NULL} is returned.
#'
#' @seealso \code{\link{check_onland}}
#' @export
lookup_xy <- function(data, shoredistance=TRUE, grids= TRUE, areas=FALSE, asdataframe=TRUE) {
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

  # Prepare message
  splists <- unname(split(as.matrix(uniquesp), seq(nrow(uniquesp))))
  msg <- RcppMsgPack::msgpackPack(list(points=splists, shoredistance=shoredistance, grids=grids, areas=areas))

  # Call service
  url <- getOption("obistools_xylookup_url", "http://api.iobis.org/lookup/")
  response <- httr::POST(url, httr::content_type("application/msgpack"),
                         httr::user_agent("obistools - https://github.com/iobis/obistools"), body=msg)

  # Parse result
  raw_content <- httr::content(response)
  if(response$status_code != 200) {
    if(is.list(raw_content) && all(c("title", "description") %in% names(raw_content))) {
      stop(paste0(raw_content$title, ": ", raw_content$description))
    }
    stop(raw_content)
  }
  content <- RcppMsgPack::msgpackUnpack(raw_content, simplify = TRUE)

  # Merge area results
  if(areas && length(content) > 0) {
    for(i in 1:length(content)) {
      careas <- content[[i]]$areas
      if(length(careas) > 0) {
        for (layer in names(careas)) {
          content[[i]]$areas[[layer]] <- bind_rows(lapply(careas[[layer]], as.list))
        }
      }
    }
  }
  # Ensure consistent shoredistance results
  if (!areas && !grids && length(content) > 0) {
    content <- lapply(content, function(x) list(shoredistance=unname(x)))
  }

  if(asdataframe) {
    # Convert to dataframe while ensuring that:
    # 1. area is a nested list in the data.frame
    # 2. grids and shoredistance results are columns
    # 3. NA values are written for coordinates that were not OK (!isclean)
    # 4. results for the non-unique coordinates are duplicated
    df <- data.frame(row.names = 1:length(content))
    if(areas) {
      df <- data_frame(areas=lapply(content, function(x) as.data.frame(x$areas)))
    }
    if(grids) {
      df <- bind_cols(bind_rows(lapply(content, function(x) as.list(x$grids))), df)
    }
    if(shoredistance) {
      df <- bind_cols(data.frame(shoredistance=sapply(content, function(x) x$shoredistance)), df)
    }
    output <- setNames(data.frame(matrix(ncol=NCOL(df), nrow=NROW(sp))), colnames(df))
    output[isclean,] <- df[duplicated_lookup,]
  } else {
    # Convert to list, keep into account invalid coordinates and duplicate coordinates
    output <- list()
    output[isclean] <- content[duplicated_lookup]
  }
  return(output)
}
