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
    m <- m + coord_quickmap(xlim = xrange, ylim = yrange)
  }

  return(m)

}

#' Identify a point on a map.
#'
#' @return The nearest record.
#' @export
identify_map <- function(data) {

  tree <- as.character(current.vpTree())
  panel <- str_match(tree, "\\[(panel.*?)\\]")[1, 2]
  seekViewport(panel)
  g <- grid.locator("npc")
  nx <- as.numeric(g$x)
  ny <- as.numeric(g$y)
  l <- last_plot()
  b <- ggplot_build(l)
  ranges <- b$layout$panel_ranges[[1]]
  xrange <- ranges$x.range
  yrange <- ranges$y.range
  px <- xrange[1] + nx * diff(xrange)
  py <- yrange[1] + ny * diff(yrange)

  sp <- b$data[[2]] %>% select(x, y)
  coordinates(sp) <- ~ x + y
  p <- SpatialPoints(matrix(c(px, py), ncol = 2, byrow = TRUE))

  d <- gDistance(p, sp, byid = TRUE)
  i <- which.min(d)
  return(data[i,])

}



