add_depth_error <- function(result, column, i, message) {
  if (length(i) > 0) {
    result <- rbind(result, data.frame(field = column, level = 'error', row = i, message = message, stringsAsFactors = FALSE))
  }
  return(result)
}

check_depth_column <- function(result, data, column, lookupvalues, depthmargin, shoremargin) {
  if (column %in% colnames(data)) {
    depths <- as.numeric(as.character(data[,column]))
    if(all(data[,column] == '')) {
      result <- rbind(result, data.frame(field=column, level = 'warning', row = NA,
                                         message = paste('Column',column,'empty'), stringsAsFactors = FALSE))
    }
    invalid <- which(is.na(depths) & data[,column] != '')
    result <- add_depth_error(result, column, invalid, 'Depth value is not numeric and not empty')

    gridwrong <- which(!is.na(depths) & depths > 0 & depths > (lookupvalues$bathymetry + rep(depthmargin, nrow(lookupvalues))))
    result <- add_depth_error(result, column, gridwrong, paste0('Depth value is greater than the value found in the bathymetry raster (depth margin=',depthmargin,')'))

    if(!is.na(shoremargin)) {
      negativewrong <- which(!is.na(depths) & depths < 0 & ((lookupvalues$shoredistance - rep(shoremargin, nrow(lookupvalues))) > 0))
      result <- add_depth_error(result, column, negativewrong, paste0('Depth value is negative for offshore points (shoredistance margin=', shoremargin,')'))
    }
  } else {
    result <- rbind(result, data.frame(field = column, level = 'warning', row = NA,
                                       message = paste('Column',column,'missing')))
  }
  return(result)
}


#' Check which points are located on land.
#'
#' @usage check_depth(data, depthmargin = 0, shoremargin = NA, report = FALSE)
#'
#' @param data The data frame.
#' @param depthmargin How much can the given depth deviate from the bathymetry
#'   in the rasters (in meters).
#' @param shoremargin How far offshore should a record be to have a bathymetry
#'   larger then 0. If \code{NA} (default) then this test is ignored
#' @param report If TRUE, errors are returned instead of records.
#'
#' @details Multiple checks are performed in this function:
#' \enumerate{
#'   \item missing depth column (warning)
#'   \item empty depth column (warning)
#'   \item depth values that can't be converted to numbers (error)
#'   \item depth values that are larger than the depth value in the bathymetry
#'   layer, after applying the provided \code{depthmargin} (error)
#'   \item depth values that are negative for off shore points, after applying
#'   the provided \code{shoremargin} (error)
#'   \item minimum depth greater than maximum depth (error)
#' }
#' @return Errors or records.
#' @seealso \code{\link{check_onland}} \code{\link{check_depth}}
#' @export
check_depth <- function(data, depthmargin = 0, shoremargin = NA, report = FALSE) {
  lookupvalues <- lookup_xy(data, shoredistance = !is.na(shoremargin), grids = TRUE, areas = FALSE)
  result <- data.frame(
    level = character(),
    row = integer(),
    field = character(),
    message = character(),
    stringsAsFactors = FALSE
  )

  depthcols <- c('minimumDepthInMeters', 'maximumDepthInMeters')
  for(column in depthcols) {
    result <- check_depth_column(result, data, column, lookupvalues, depthmargin, shoremargin)
  }

  if(all(depthcols %in% colnames(data))) {
    mind <- as.numeric(as.character(data[,depthcols[1]]))
    maxd <- as.numeric(as.character(data[,depthcols[2]]))
    minGTmax <- which(!is.na(maxd) & !is.na(mind) & mind > maxd)
    result <- add_depth_error(result, depthcols, minGTmax, "Minimum depth is greater than maximum depth")
  }

  if (report) {
    return(result)
  } else if(nrow(result) > 0 && length(na.omit(result$row)) > 0) {
    return(data[sort(unique(na.omit(result$row))),])
  }
}
