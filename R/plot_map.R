#' Plot occurrences on a map.
#'
#' @param data The data frame.
#' @export
plot_map <- function(data, zoom = FALSE) {

  world <- borders("world", colour="gray80", fill="gray80")
  m <- ggplot() +
    world +
    geom_point(data = data, aes(x = decimalLongitude, y = decimalLatitude), size = 2, stroke = 1, alpha = 0.3, colour = "#FF368B") +
    xlab("longitude") +
    ylab("latitude") +
    coord_quickmap()

  if (zoom) {
    xrange <- range(data$decimalLongitude)
    yrange <- range(data$decimalLatitude)
    margin <- 0.3
    dx <- margin * (xrange[2] - xrange[1])
    dy <- margin * (yrange[2] - yrange[1])
    xrange[1] <- xrange[1] - dx
    xrange[2] <- xrange[2] + dx
    yrange[1] <- yrange[1] - dy
    yrange[2] <- yrange[2] + dy
    m <- m + coord_map(xlim = xrange, ylim = yrange)
  }

  return(m)

}
