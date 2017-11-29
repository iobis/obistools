add_depth_error <- function(result, data, columns, i, message, extra_data=NULL) {
  if (length(i) > 0) {
    args <- list("fmt" = message)
    for(column in columns) {
      args[[column]] <- data[i,column]
    }
    if(length(extra_data) > 0) {
      args[["extra_data"]] <- extra_data[i]
    }
    message <- do.call(sprintf, args)
    result <- rbind(result, data.frame(field = rep(columns, length(i)), level = 'error', row = i, message = message, stringsAsFactors = FALSE))
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
    result <- add_depth_error(result, data, column, invalid, 'Depth value (%s) is not numeric and not empty')

    gridwrong <- which(!is.na(depths) & depths > 0 & depths > (lookupvalues$bathymetry + rep(depthmargin, nrow(lookupvalues))))
    result <- add_depth_error(result, data, column, gridwrong, paste0('Depth value (%s) is greater than the value found in the bathymetry raster (depth=%0.1f, margin=',depthmargin,')'),lookupvalues$bathymetry)

    if(!is.na(shoremargin)) {
      negativewrong <- which(!is.na(depths) & depths < 0 & ((lookupvalues$shoredistance - rep(shoremargin, nrow(lookupvalues))) > 0))
      result <- add_depth_error(result, data, column, negativewrong, paste0('Depth value (%s) is negative for offshore points (shoredistance=%s, margin=', shoremargin,')'),lookupvalues$shoredistance)
    }
  } else {
    result <- rbind(result, data.frame(field = column, level = 'warning', row = NA,
                                       message = paste('Column',column,'missing')))
  }
  return(result)
}


#' Check which points are located on land.
#'
#' @usage check_depth(data, bathymetry, depthmargin = 0, shoremargin = NA,
#'   report = FALSE)
#'
#' @param data The data frame.
#' @param bathymetry Raster* object that you want to use to check the depth
#'   against. If \code{NULL} (default) then the bathymetry from the xylookup
#'   service is used.
#' @param depthmargin How much can the given depth deviate from the bathymetry
#'   in the rasters (in meters).
#' @param shoremargin How far offshore should a record be to have a bathymetry
#'   larger then 0. If \code{NA} (default) then this test is ignored.
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
#' @return Records or an errors report.
#' @seealso \code{\link{check_onland}} \code{\link{check_depth}}
#' @export
check_depth <- function(data, bathymetry=NULL, depthmargin = 0, shoremargin = NA, report = FALSE) {
  original_data <- data
  data <- as.data.frame(data) # make sure it is a data frame and not a tibble or anything else
  if(is.null(bathymetry)) {
    lookupvalues <- lookup_xy(data, shoredistance = !is.na(shoremargin), grids = TRUE, areas = FALSE)
  } else if (!"raster" %in% class(bathymetry)){
    lookupvalues <- lookup_xy(data, shoredistance = !is.na(shoremargin), grids = FALSE, areas = FALSE)
    xy <- get_xy_clean_duplicates(data) # make sure to lookup no duplicated points and points outside
    cells <- raster::cellFromXY(bathymetry, xy$uniquesp)
    values <- raster::extract(bathymetry, cells)
    lookupvalues[xy$isclean, "bathymetry"] <- values[xy$duplicated_lookup]
  }

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
    result <- add_depth_error(result, data, depthcols, minGTmax, "Minimum depth [%s] is greater than maximum depth [%s]")
  }

  if (!report) {
    result <- original_data[sort(unique(na.omit(result$row))),]
  }
  return(result)
}
