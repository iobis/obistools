#' Calculates the centroid and radius of a WKT geometry.
#'
#' @param wkt character vector One or more WKT strings with longitude/latitude
#'   coordinates (epsg=4326)
#' @return Data frame with centroid coordinates and radius in meter.
#' @export
calculate_centroid <- function(wkt) {
  results <- lapply(wkt, function(wkt) {
    s <- sf::st_as_sfc(wkt)
    p <- sf::st_cast(s, "POINT")
    mp <- sf::st_combine(p)
    h <- sf::st_convex_hull(mp)
    if(length(sf::st_geometry_type(h)) > 1) {
      print(wkt)
      print(sf::st_geometry_type(h))
    }
    hxy <- sf::st_coordinates(h)[,c('X', 'Y')]
    if (sf::st_geometry_type(h) == "POINT"){
        centroid <- hxy
    } else if (sf::st_geometry_type(h) == "LINESTRING" && nrow(hxy) == 2) {
        centroid <- geosphere::midPoint(hxy[1,], hxy[2,])
    } else if (sf::st_geometry_type(h) == "POLYGON"){
      centroid <- geosphere::centroid(hxy)
    }
    return(data.frame(
      decimalLongitude = centroid[1],
      decimalLatitude = centroid[2],
      coordinateUncertaintyInMeters = max(geosphere::distm(centroid, hxy))
    ))
  })
  ## previous implementation
  # results <- lapply(wkt, function(wkt) {
  #   s <- readWKT(wkt, p4s = CRS("+init=epsg:4326"))
  #   centroid <- gCentroid(s)
  #   h <- gConvexHull(s)
  #   m <- h[1]@polygons[[1]]@Polygons[[1]]@coords
  #   return(data.frame(
  #     decimalLongitude = centroid$x,
  #     decimalLatitude = centroid$y,
  #     coordinateUncertaintyInMeters = max(distm(as.data.frame(centroid), m))
  #   ))
  # })
  return(bind_rows(results))
}
