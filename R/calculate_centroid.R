#' Calculates the centroid and radius of a WKT geometry.
#'
#' @param WKT strings.
#' @return Table with centroid coordinates and radius in meter.
#' @export
calculate_centroid <- function(wkt) {
  results <- lapply(wkt, function(wkt) {
    s <- readWKT(wkt, p4s = CRS("+init=epsg:4326"))
    centroid <- gCentroid(s)
    h <- gConvexHull(s)
    m <- h[1]@polygons[[1]]@Polygons[[1]]@coords
    return(data.frame(
      decimalLongitude = centroid$x,
      decimalLatitude = centroid$y,
      coordinateUncertaintyInMeters = max(distm(as.data.frame(centroid), m))
    ))
  })
  return(bind_rows(results))
}
