#' Plot occurrences on a map.
#'
#' @param data The data frame.
#' @param zoom Zoom to the occurrences (default: \code{FALSE}).
#' @examples
#' plot_map(abra)
#' plot_map(abra, zoom = TRUE)
#' @export
plot_map <- function(data, zoom = FALSE) {
  check_lonlat(data, FALSE)
  m <- NULL
  data <- get_xy_clean(data)
  if(NROW(data) > 0) {
    world <- borders("world", colour="gray80", fill="gray80")
    m <- ggplot() +
      world +
      geom_point(data = data, aes(x = decimalLongitude, y = decimalLatitude), size = 2, stroke = 1, alpha = 0.3, colour = "#FF368B") +
      xlab("longitude") +
      ylab("latitude")

    xrange <- range(data$decimalLongitude, na.rm = TRUE)
    yrange <- range(data$decimalLatitude, na.rm = TRUE)

    if (zoom & all(is.finite(xrange)) & all(is.finite(yrange))) {
      margin <- 0.3
      dx <- margin * (xrange[2] - xrange[1])
      dy <- margin * (yrange[2] - yrange[1])
      xrange[1] <- xrange[1] - dx
      xrange[2] <- xrange[2] + dx
      yrange[1] <- yrange[1] - dy
      yrange[2] <- yrange[2] + dy
      m <- m + coord_quickmap(xlim = xrange, ylim = yrange)
    } else {
      m <- m + coord_quickmap()
    }
  } else {
    warning("No valid coordinates found for plotting")
  }
  return(m)

}

#' Deprecated: Identify a point on a map.
#'
#' @param data Original data that was plotted on the map.
#' @return The nearest record.
#' @examples
#' \dontrun{
#' plot_map(abra, zoom = TRUE)
#' identify_map(abra)
#' }
#' @export
identify_map <- function(data) {
  .Deprecated()
  if(nzchar(Sys.getenv("RSTUDIO_USER_IDENTITY"))) {
    warning("This function returns incorrect results in some versions of RStudio")
  }
  stopifnot(requireNamespace("grid"))
  tree <- as.character(grid::current.vpTree())
  panel <- str_match(tree, "\\[(panel.*?)\\]")[1, 2]
  grid::seekViewport(panel)
  g <- grid::grid.locator("npc")
  nx <- as.numeric(g$x)
  ny <- as.numeric(g$y)
  l <- last_plot()
  b <- ggplot_build(l)
  params <- b$layout$panel_params[[1]]

  xrange <- params$x.range
  yrange <- params$y.range
  px <- xrange[1] + nx * diff(xrange)
  py <- yrange[1] + ny * diff(yrange)

  sp <- b$data[[2]] %>% select(x, y)
  coordinates(sp) <- ~ x + y
  p <- SpatialPoints(matrix(c(px, py), ncol = 2, byrow = TRUE))

  d <- gDistance(p, sp, byid = TRUE)
  i <- which.min(d)
  return(data[i,])
}

#' Create a Leaflet map.
#'
#' @param data The data frame.
#' @param provider Tile provider, see
#'   https://leaflet-extras.github.io/leaflet-providers/preview/.
#' @param popup The field to display as a popup or a character vector with as
#'   many elements as there are rows, by default the row names are shown.
#' @return HTML widget object.
#' @examples
#' plot_map_leaflet(abra)
#' plot_map_leaflet(abra, popup = "datasetID")
#' plot_map_leaflet(abra, popup = head(colnames(abra)))
#' @export
plot_map_leaflet <- function(data, provider = "Esri.OceanBasemap", popup = NULL) {
  check_lonlat(data, FALSE)
  if (!is.null(popup) && all(popup %in% names(data))) {
    if(length(popup) == 1) {
      popupdata <- as.character(data[,popup])
    } else {
      popupdata <- apply(data[,popup], 1, knitr::kable, format="html")
      popupdata <- gsub("<thead>.*</thead>", "", popupdata) # remove column header
    }
  } else if (length(popup) == NROW(data)) {
    popupdata <- as.character(popup)
  } else {
    popupdata <- as.character(rownames(data))
  }

  m <- leaflet(data) %>%
    addProviderTiles(provider) %>%
    addCircleMarkers(~decimalLongitude, ~decimalLatitude, popup = popupdata, radius = 3, weight = 1, fillColor = "#FF368B", color = "#FF368B", opacity = 1, fillOpacity = 0.1)
  return(m)
}
