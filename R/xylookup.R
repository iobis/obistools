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
#' @seealso \code{\link{check_onland}} \code{\link{check_depth}}
#' @export
lookup_xy <- function(data, shoredistance=TRUE, grids=TRUE, areas=FALSE, asdataframe=TRUE) {
  xy <- get_xy_clean_duplicates(data)

  # Prepare message
  splists <- unname(split(as.matrix(xy$uniquesp), seq(nrow(xy$uniquesp))))
  msg <- jsonlite::toJSON(list(points=splists, shoredistance=shoredistance, grids=grids, areas=areas), auto_unbox=T)

  # Call service
  url <- getOption("obistools_xylookup_url", "http://api.iobis.org/xylookup/")
  response <- httr::POST(url, httr::content_type("application/json"),
                         httr::user_agent("obistools - https://github.com/iobis/obistools"), body=msg)

  # Parse result
  raw_content <- httr::content(response, as="raw")
  if(response$status_code != 200) {
    if(is.list(raw_content) && all(c("title", "description") %in% names(raw_content))) {
      stop(paste0(raw_content$title, ": ", raw_content$description))
    }
    stop(rawToChar(raw_content))
  }
  content <- jsonlite::fromJSON(rawToChar(raw_content), simplifyVector = asdataframe)

  if(asdataframe) {
    # Convert to dataframe while ensuring that:
    # 1. area is a nested list in the data.frame
    # 2. grids and shoredistance results are columns
    # 3. NA values are written for coordinates that were not OK (!isclean)
    # 4. results for the non-unique coordinates are duplicated
    content <- as.data.frame(content)
    df <- data.frame(row.names = 1:NROW(content))
    if (shoredistance) {
      df <- cbind(df, shoredistance=content[,"shoredistance", drop=TRUE])
    }
    if (grids) {
      df <- merge(df, content[,"grids", drop=TRUE], by=0, sort = FALSE)[,-1]
    }
    if (areas) {
      df <- merge(df, content[,"areas", drop=TRUE], by=0, sort = FALSE)[,-1]
    }
    output <- setNames(data.frame(matrix(ncol=NCOL(df), nrow=NROW(data))), colnames(df))
    output[xy$isclean,] <- df[xy$duplicated_lookup,]
  } else {
    # Convert to list, keep into account invalid coordinates and duplicate coordinates
    output <- list()
    output[xy$isclean] <- content[xy$duplicated_lookup]
  }
  return(output)
}
