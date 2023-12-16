#' Calculates the centroid and radius of a WKT geometry.
#'
#' @param wkt character vector One or more WKT strings with longitude/latitude
#'   coordinates (epsg=4326)
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
    s <- sf::st_as_sfc(wkt)
    p <- sf::st_cast(s, "POINT")
    mp <- sf::st_combine(p)
    h <- sf::st_convex_hull(mp)
    stopifnot(length(sf::st_geometry_type(h)) == 1 || is.null("calculate_centroid: hull should be a single geometry type"))
    centroid <- sf::st_centroid(h)
    centroid_vect <- terra::vect(centroid %>% sf::st_set_crs(4326))
    hull_vect <- terra::vect(p %>% sf::st_set_crs(4326))
    return(data.frame(
      decimalLongitude = sf::st_coordinates(centroid)[1],
      decimalLatitude = sf::st_coordinates(centroid)[2],
      coordinateUncertaintyInMeters = max(terra::distance(centroid_vect, hull_vect))
    ))
  })
  return(bind_rows(results))
}
