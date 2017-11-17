add_depth_error <- function(report, column, i, message) {
  if (length(i) > 0) {
    report <- rbind(report, list(field = column, level = 'error', row = i, message = message))
  }
  return(report)
}

check_depth_column <- function(report, data, column, lookupvalues, depthmargin, shoremargin) {
  if (column %in% colnames(data)) {
    depths <- as.numeric(data[,column])
    if(all(data[,column] == '')) {
      report <- rbind(report, list(level = 'warning',
                                   message = paste('Column',column,'empty')))
    }
    invalid <- which(is.na(depths) & data[,column] != '')
    report <- add_depth_error(report, column, invalid, 'Depth value is not numeric and not empty')

    gridwrong <- which(!is.na(depths) & depths > (lookupvalues$bathymetry + depthmargin))
    report <- add_depth_error(report, column, gridwrong, paste0('Depth value is larger than the value found in the bathymetry raster (depth margin=',depthmargin,')'))

    negativewrong <- which(!is.na(depths) & depths < 0 & (lookupvalues$shoredistance - shoremargin > 0))
    report <- add_depth_error(report, column, negativewrong, paste0('Depth value is negative than the value found in the bathymetry raster (shoredistance margin=', shoremargin,')'))
  } else {
    report <- rbind(report, list(level = 'warning',
                                 field = column,
                                 message = paste('Column',column,'missing')))
  }
  return(report)
}


#' Check which points are located on land.
#'
#' @usage check_depth(data, report = FALSE)
#'
#' @param data The data frame.
#' @param depthmargin How much can the given depth deviate from the bathymetry
#'   in the rasters (in meters).
#' @param shoremargin How far offshore should a record be to have a bathymetry
#'   larger then 0.
#' @param report If TRUE, errors are returned instead of records.
#'
#' @return Errors or records.
#' @export
check_depth <- function(data, depthmargin = 0, shoremargin = 0, report = FALSE) {
  lookupvalues <- lookup_xy(data, shoredistance = TRUE, areas = FALSE)
  report <- data.frame(
    level = character(),
    row = integer(),
    field = character(),
    message = character(),
    stringsAsFactors = FALSE
  )

  depthcols <- c('minimumDepthInMeters', 'maximumDepthInMeters')
  for(col in depthcols) {
    report <- check_depth_column(report, data, col, lookupvalues, depthmargin, shoremargin)
  }

  if(all(depthcols) %in% colnames(data)) {
    mind <- as.numeric(data[depthcols[1],])
    maxd <- as.numeric(data[depthcols[2],])
    minGTmax <- which(!is.na(maxd) & !is.na(mind) & mind > maxd)
    report <- add_depth_error(report, depthcols, minGTmax, "Minimum depth is larger then maximum depth")
  }

  if (report) {
    return(report)
  } else {
    return(data[na.omit(report$row),])
  }
}
