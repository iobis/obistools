add_depth_message <- function(result, data, columns, i, message, extra_data=NULL, level='warning') {
  if(is.logical(i)) {
    i <- which(i)
  }
  if (length(i) > 0) {
    args <- list('fmt' = message)
    for(column in columns) {
      args[[column]] <- data[i,column]
    }
    if(length(extra_data) > 0) {
      args[['extra_data']] <- extra_data[i]
    }
    message <- do.call(sprintf, args)
    result <- rbind(result, data_frame(level = level, row = i, field = rep(columns, length(i)), message = message))
  }
  return(result)
}

check_depth_column <- function(result, data, column, lookupvalues, depthmargin, shoremargin) {
  if (column %in% colnames(data)) {
    depths <- as.numeric(as.character(data[,column]))
    if(all(is.na(data[[column]]) | data[[column]] == '')) {
      result <- rbind(result, data_frame(level = 'warning', row = NA, field=column,
                                         message = paste('Column',column,'empty')))
    }
    invalid <- is.na(depths) & data[,column] != ''
    result <- add_depth_message(result, data, column, invalid, 'Depth value (%s) is not numeric and not empty')

    gridwrong <- !is.na(depths) & depths > 0 & !is.na(lookupvalues$bathymetry) & depths > (lookupvalues$bathymetry + rep(depthmargin, nrow(lookupvalues)))
    result <- add_depth_message(result, data, column, gridwrong, paste0('Depth value (%s) is greater than the value found in the bathymetry raster (depth=%0.1f, margin=',depthmargin,')'),lookupvalues$bathymetry)

    if(!is.na(shoremargin)) {
      negativewrong <- !is.na(depths) & depths < 0 & ((lookupvalues$shoredistance - rep(shoremargin, nrow(lookupvalues))) > 0)
      result <- add_depth_message(result, data, column, negativewrong, paste0('Depth value (%s) is negative for offshore points (shoredistance=%s, margin=', shoremargin,')'),lookupvalues$shoredistance)
    }
  } else {
    result <- rbind(result, data_frame(level = 'warning', row = NA, field = column,
                                       message = paste('Column',column,'missing')))
  }
  return(result)
}


#' Check which points have potentially invalid depths.
#'
#' @usage check_depth(data, report = FALSE, depthmargin = 0, shoremargin = NA,
#'   bathymetry = NULL)
#'
#' @param data The data frame.
#' @param report If TRUE, errors are returned instead of records.
#' @param depthmargin How much can the given depth deviate from the bathymetry
#'   in the rasters (in meters).
#' @param shoremargin How far offshore (in meters) should a record be to have a
#'   bathymetry greater than 0. If \code{NA} (default) then this test is
#'   ignored.
#' @param bathymetry Raster* object that you want to use to check the depth
#'   against. If \code{NULL} (default) then the bathymetry from the xylookup
#'   service is used.
#'
#' @details Multiple checks are performed in this function: \enumerate{ \item
#'   missing depth column (warning) \item empty depth column (warning) \item
#'   depth values that can't be converted to numbers (error) \item depth values
#'   that are larger than the depth value in the bathymetry layer, after
#'   applying the provided \code{depthmargin} (error) \item depth values that
#'   are negative for off shore points, after applying the provided
#'   \code{shoremargin} (error) \item minimum depth greater than maximum depth
#'   (error) }
#' @return Problematic records or an errors report.
#' @examples
#' \dontrun{
#' notok <- check_depth(abra, report = FALSE)
#' print(nrow(notok))
#' r <- check_depth(abra, report = TRUE, depthmargin = 100, shoremargin = 100)
#' print(r)
#' plot_map_leaflet(abra[r$row,], popup = "id")
#' }
#' @seealso \code{\link{check_onland}} \code{\link{check_outliers_dataset}}
#'   \code{\link{check_outliers_species}} \code{\link{lookup_xy}}
#' @export
check_depth <- function(data, report = FALSE, depthmargin = 0, shoremargin = NA, bathymetry=NULL) {
  errors <- check_lonlat(data, report)
  if (NROW(errors) > 0 && report) {
    return(errors)
  }
  result <- data_frame(
    level = character(),
    row = integer(),
    field = character(),
    message = character()
  )
  original_data <- data
  data <- as.data.frame(data) # make sure it is a data frame and not a tibble or anything else
  xmin <- -180
  ymin <- -90
  xmax <- 180
  ymax <- 90
  if(is.null(bathymetry)) {
    lookupvalues <- lookup_xy(data, shoredistance = !is.na(shoremargin), grids = TRUE, areas = FALSE)
  } else if (inherits(bathymetry, "Raster")){
    stopifnot(raster::nlayers(bathymetry) == 1 && !is.null("Only one bathymetry raster can be provided"))
    if(!is.na(shoremargin)) {
      lookupvalues <- lookup_xy(data, shoredistance = TRUE, grids = FALSE, areas = FALSE)
    } else {
      lookupvalues <- data.frame(row.names = seq_len(nrow(data)))
    }
    xy <- get_xy_clean_duplicates(data) # make sure to lookup no duplicated points and points outside
    cells <- raster::cellFromXY(bathymetry, xy$uniquesp)
    values <- raster::extract(bathymetry, cells)
    lookupvalues[xy$isclean, "bathymetry"] <- values[xy$duplicated_lookup]
    xmin <- raster::xmin(bathymetry)
    ymin <- raster::ymin(bathymetry)
    xmax <- raster::xmax(bathymetry)
    ymax <- raster::ymax(bathymetry)
  } else {
    stop("bathymetry should be a raster")
  }

  depthcols <- c('minimumDepthInMeters', 'maximumDepthInMeters')

  if(all(depthcols %in% colnames(data))) {
    mind <- as.numeric(as.character(data[,depthcols[1]]))
    maxd <- as.numeric(as.character(data[,depthcols[2]]))
    minGTmax <- !is.na(maxd) & !is.na(mind) & mind > maxd
    result <- add_depth_message(result, data, depthcols[1], minGTmax, 'Minimum depth [%s] is greater than maximum depth [%s]', extra_data = data$maximumDepthInMeters, level='error')
  }

  for(column in depthcols) {
    result <- check_depth_column(result, data, column, lookupvalues, depthmargin, shoremargin)
  }

  # handle longitude/latitude outside bathymetry raster / world bounds
  wrong_x <- is.na(data$decimalLongitude) | data$decimalLongitude < xmin | data$decimalLongitude > xmax
  wrong_y <- is.na(data$decimalLatitude) | data$decimalLatitude < ymin | data$decimalLatitude > ymax
  result <- add_depth_message(result, data, "decimalLongitude", wrong_x, "Longitude [%s] is outside the bounds of the provided raster (%s)", rep(paste(xmin, xmax), nrow(data)), level="warning")
  result <- add_depth_message(result, data, "decimalLatitude", wrong_y, "Latitude [%s] is outside the bounds of the provided raster (%s)", rep(paste(ymin, ymax), nrow(data)), level="warning")
  # handle NA values in raster/lookup
  result <- add_depth_message(result, data, "decimalLongitude", is.na(lookupvalues$bathymetry), "No bathymetry value found for coordinate (%s, %s)", level="warning", extra_data = data$decimalLatitude)

  if (!report) {
    result <- original_data[sort(unique(stats::na.omit(result$row))),]
  }
  return(result)
}
