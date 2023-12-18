#' Calculates the centroid and radius of a WKT geometry.
#'
#' @param wkt character vector One or more WKT strings with longitude/latitude
#'   coordinates (EPSG=4326)
#' @details The centroid is defined as the centroid of the convex hull of the
#'   provided geometry.
#' @return Data frame with centroid coordinates and radius in meter.
#' @examples
#' calculate_centroid("POLYGON ((-1 -1, -1 1, 1 1, 1 -1, -1 -1))")
#' calculate_centroid("MULTIPOLYGON (((-1 -1, -1 1, 1 1, 1 -1, -1 -1)))")
#' calculate_centroid("LINESTRING (-1 -1, 0 -1, 0 1, 1 1)")
#' calculate_centroid("MULTILINESTRING ((-1 -1, 0 -1, 0 1, 1 1), (-3 -3, 3 3))")
#' calculate_centroid("POINT (0 0)")
#' calculate_centroid("MULTIPOINT ((0 1), (0 -1))")
#' @export
calculate_centroid <- function(wkt) {
  results <- lapply(wkt, function(wkt) {
    # Temporary workaround, due to a problem with MULTIPOINTS.
    # Already in contact with maintainer of terra for better solution
    if (grepl("MULTIPOINT", wkt)) {
      s <- terra::vect(terra::crds(terra::vect(wkt)))
    } else {
      s <- terra::vect(wkt)
    }
    p <- suppressWarnings(terra::as.points(s, skiplast = FALSE))
    h <- terra::convHull(s)

    stopifnot(length(terra::geomtype(h)) == 1 || is.null("calculate_centroid: hull should be a single geometry type"))

    centroid <- terra::centroids(h)
    terra::crs(p) <- terra::crs(centroid) <- "EPSG:4326"

    return(data.frame(
      decimalLongitude = terra::crds(centroid)[1],
      decimalLatitude = terra::crds(centroid)[2],
      coordinateUncertaintyInMeters = max(terra::distance(centroid, p))
    ))
  })
  return(bind_rows(results))
}
