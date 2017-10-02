#' Lookup spatial data for a set of points.
#'
#' @usage lookup_xy(data, shoredistance=TRUE, grids=TRUE, areas=FALSE, verbose=FALSE)
#'
#' @param data The data frame with columns decimalLongitude and decimalLatitude.
#' @param shoredistance Indicate whether the shoredistance should be returned
#'   (default \code{TRUE}).
#' @param grids Indictate whether the grid values such as temperature and
#'   bathymetry should be returned (default \code{TRUE})
#' @param areas Indictate whether the area values should be returned (default
#'   \code{FALSE}).
#' @return Data frame with the values for the different requested fields.
#' @details Data is returned in the same order as the requested data
#' @seealso \link{\code{check_onland}}
#' @export
lookup_xy <- function(data, shoredistance=TRUE, grids= TRUE, areas=FALSE, verbose=FALSE) {
  sp <- data %>% select(decimalLongitude, decimalLatitude)
  url <-  getOption("obistools_xylookup_url", "http://envocean/lookup/")

  sp <- sp[rep(c(1,2,3), 1000),]
  # system.time({
  # parameters <- list(x=I(paste0(sp$decimalLongitude, collapse=",")), y=I(paste0(sp$decimalLatitude, collapse=",")))
  # response <- httr::GET(url, httr::user_agent("obistools - https://github.com/iobis/obistools"), query = parameters)
  # text <- httr::content(response, "text", encoding = "UTF-8")
  # res <- jsonlite::fromJSON(text, simplifyVector = TRUE)
  # #colnames(res) <- sub()

  splists <- unname(split(as.matrix(sp), seq(nrow(sp))))
  msg <- msgpackR::pack(list(points=splists))

  url <- "http://localhost:8000/lookup"
  response <- httr::POST(url, httr::content_type("application/msgpack"),
                         httr::user_agent("obistools - https://github.com/iobis/obistools"), body=msg)
  raw_content <- httr::content(response)
  content <- msgpackR::unpack(raw_content)

  if (verbose) {
    print(head(content))
  }
  return(content)
}
