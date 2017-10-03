#' Check which points are located on land.
#'
#' @param data The data frame.
#' @param polygons SpatialPolygonsDataFrame. If not provided the simplified land
#'   polygons from OSM are used. This parameter is ignored when, \code{offline =
#'   FALSE}.
#' @param report If TRUE, errors are returned instead of records.
#' @param buffer Set how far inland points are still to be deemed valid (in meters).
#' @param offline If TRUE, a local simplified shoreline is used, otherwise an
#'   OBIS webservice is used. The default value is \code{FALSE}.
#'
#' @return Errors or records.
#' @export
check_onland <- function(data, polygons = NULL, report = FALSE, buffer=0, offline = FALSE) {

  if (is.null(polygons)) {
    polygons <- land
  } else if(!offline) {
    warning("The polygons parameters is not supported when offline = FALSE")
  }
  if (buffer !=0 && offline) {
    warning("The buffer parameter is not supported when offline = TRUE")
  }

  if(offline) {
    sp <- data %>% select(decimalLongitude, decimalLatitude)
    coordinates(sp) <- ~ decimalLongitude + decimalLatitude
    proj4string(sp) <- CRS("+init=epsg:4326")
    sp <- spTransform(sp, proj4string(polygons))
    i <- which(!is.na(over(sp, polygons)))
  } else {
    shoredistances <- lookup_xy(data, shoredistance = TRUE, grids = FALSE, areas = FALSE, asdataframe = TRUE)
    i <- which(as.vector(shoredistances) < (-1*buffer))
  }
  if (report) {
    if (length(i) > 0) {
      return(data.frame(
        field = NA,
        level = "warning",
        row = i,
        message = paste0("Coordinates are located on land"),
        stringsAsFactors = FALSE
      ))
    } else {
      return(data.frame())
    }
  } else {
    return(data[i,])
  }

}
