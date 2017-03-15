#' Check which points are located on land.
#'
#' @param data The data frame.
#' @param polygons SpatialPolygonsDataFrame. If not provided the simplified land polygons from OSM are used.
#' @param report If TRUE, errors are returned instead of records
#' @return Errors or records.
#' @export
check_onland <- function(data, polygons = NULL, report = FALSE) {

  if (is.null(polygons)) {
    polygons <- land
  }

  sp <- data %>% select(decimalLongitude, decimalLatitude)
  coordinates(sp) <- ~ decimalLongitude + decimalLatitude
  proj4string(sp) <- CRS("+init=epsg:4326")
  sp <- spTransform(sp, proj4string(polygons))
  i <- which(!is.na(over(sp, polygons)))

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
