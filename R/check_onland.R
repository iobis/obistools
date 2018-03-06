#' Check which points are located on land.
#'
#' @param data The data frame.
#' @param land SpatialPolygonsDataFrame. If not provided the simplified land
#'   polygons from OSM are used. This parameter is ignored when, \code{offline =
#'   FALSE}.
#' @param report If TRUE, errors are returned instead of records.
#' @param buffer Set how far inland points are still to be deemed valid (in meters).
#' @param offline If TRUE, a local simplified shoreline is used, otherwise an
#'   OBIS webservice is used. The default value is \code{FALSE}.
#'
#' @return Errors or problematic records.
#' @examples
#' \dontrun{
#' report <- check_onland(abra, report = TRUE, buffer = 100)
#' print(report)
#' # plot records on land with 100 meter buffer
#' plot_map_leaflet(abra[report$row,], popup = "id")
#' # filter records not on land
#' ok <- abra[-1 * report$row,]
#' ok <- check_onland(abra, report = FALSE, buffer = 100)
#' print(nrow(ok))
#' }
#' @seealso \code{\link{check_depth}} \code{\link{check_outliers_dataset}}
#'   \code{\link{check_outliers_species}} \code{\link{lookup_xy}}
#' @export
check_onland <- function(data, land = NULL, report = FALSE, buffer=0, offline = FALSE) {
  errors <- check_lonlat(data, report)
  if (NROW(errors) > 0 && report) {
    return(errors)
  }
  if(!is.null(land) && !offline) warning("The land parameter is not supported when offline = FALSE")
  if (buffer !=0 && offline) warning("The buffer parameter is not supported when offline = TRUE")

  if (offline && is.null(land)) {
    cache_dir <- rappdirs::user_cache_dir("obistools")
    landpath <- file.path(cache_dir, 'land.RData')
    if(!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
    if (!file.exists(landpath)) {
      utils::download.file("http://iobis.org/downloads/obistools/land.RData", landpath)
    }
    load(landpath)
  }

  if(offline) {
    sp <- data %>% select(decimalLongitude, decimalLatitude)
    coordinates(sp) <- ~ decimalLongitude + decimalLatitude
    proj4string(sp) <- CRS("+init=epsg:4326")
    sp <- spTransform(sp, proj4string(land))
    i <- which(!is.na(over(sp, land)))
  } else {
    shoredistances <- lookup_xy(data, shoredistance = TRUE, grids = FALSE, areas = FALSE, asdataframe = TRUE)
    i <- which(as.vector(shoredistances) < (-1*buffer))
  }
  if (report) {
    if (length(i) > 0) {
      return(data_frame(
        field = NA,
        level = "warning",
        row = i,
        message = paste0("Coordinates are located on land")
      ))
    } else {
      return(data_frame())
    }
  } else {
    return(data[i,])
  }
}
