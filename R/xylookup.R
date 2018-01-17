#' Lookup spatial data for a set of points.
#'
#' @usage lookup_xy(data, shoredistance=TRUE, grids=TRUE, areas=FALSE,
#'   asdataframe=TRUE)
#'
#' @param data The data frame with columns decimalLongitude and decimalLatitude.
#' @param shoredistance Indicate whether the shoredistance should be returned
#'   (default \code{TRUE}).
#' @param grids Indicate whether the grid values such as temperature and
#'   bathymetry should be returned (default \code{TRUE})
#' @param areas Indicate whether the area values should be returned (default
#'   \code{FALSE}).
#' @param asdataframe Indicate whether a dataframe or a list should be returned
#'   (default \code{TRUE}).
#'
#' @return Data frame or list with the values for the different requested
#'   fields.
#' @details When \code{asdataframe} is \code{FALSE} then data is returned in the
#'   same order as the requested data as a list, with for each list item the
#'   requested values. For invalid coordinates \code{NULL} is returned.
#' @examples
#' \dontrun{
#' lookup_xy(abra, shoredistance = TRUE, grids = TRUE, areas = FALSE)
#' }
#' @seealso \code{\link{check_onland}} \code{\link{check_depth}}
#' @export
lookup_xy <- function(data, shoredistance=TRUE, grids=TRUE, areas=FALSE, asdataframe=TRUE) {
  xy <- get_xy_clean_duplicates(data)
  if(NROW(xy$uniquesp) == 0) {
    output <- data.frame(row.names=seq_len(NROW(data)))
    if(!asdataframe) {
      # Create a list with only NULL values
      output <- list()
      output[[NROW(data)+1]] <- NA
      output[[NROW(data)+1]] <- NULL
    }
    return(output)
  } else {
    # Prepare message
    splists <- unname(split(as.matrix(xy$uniquesp), seq(nrow(xy$uniquesp))))
    # Divide in chunks of 25000 coordinates
    chunks <- split(splists, ceiling(seq_along(splists)/25000))

    content_chunks <- lapply(chunks, function(chunk) {
      msg <- jsonlite::toJSON(list(points=chunk, shoredistance=shoredistance, grids=grids, areas=areas), auto_unbox=TRUE)
      raw_content <- lookup_xy_chunk(msg)
      jsonlite::fromJSON(rawToChar(raw_content), simplifyVector = FALSE)
    })
    content <- unlist(content_chunks, recursive = FALSE, use.names = FALSE)
    if(asdataframe) {
      # Convert to dataframe while ensuring that:
      # 1. area is a nested list in the data.frame
      # 2. grids and shoredistance results are columns
      # 3. NA values are written for coordinates that were not OK (!isclean)
      # 4. results for the non-unique coordinates are duplicated
      content <- jsonlite::fromJSON(jsonlite::toJSON(content, auto_unbox = TRUE), simplifyVector = TRUE)
      content <- as.data.frame(content)
      df <- data.frame(row.names = seq_len(NROW(content)))
      if (shoredistance) {
        df <- cbind(df, shoredistance=content[,"shoredistance", drop=TRUE])
      }
      if (grids) {
        df <- merge(df, content[,"grids", drop=TRUE], by=0, sort = FALSE)[,-1]
      }
      if (areas) {
        df <- merge(df, content[,"areas", drop=TRUE], by=0, sort = FALSE)[,-1]
      }
      output <- stats::setNames(data.frame(matrix(ncol=NCOL(df), nrow=NROW(data))), colnames(df))
      output[xy$isclean,] <- df[xy$duplicated_lookup,]
    } else {
      # Convert to list, keep into account invalid coordinates and duplicate coordinates
      output <- list()
      output[xy$isclean] <- content[xy$duplicated_lookup]
    }
    return(output)
  }
}

lookup_xy_chunk <- function(msg) {
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
  raw_content
}
