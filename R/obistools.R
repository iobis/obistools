#' obistools: Tools for data enhancement and quality control
#'
#' Work in progress
#'
#' @docType package
#' @name obistools
#' @import dplyr
#' @import ggplot2
#' @importFrom grid seekViewport
#' @importFrom grid grid.locator
#' @importFrom grid current.vpTree
#' @import sp
#' @importFrom rgeos gDistance
#' @importFrom rgeos readWKT
#' @importFrom leaflet leaflet
#' @importFrom leaflet addProviderTiles
#' @importFrom leaflet addCircleMarkers
#' @importFrom stringr str_match
#' @importFrom stringr str_split
#' @importFrom geosphere distm
#' @import rmarkdown
#' @import knitr
#' @import xml2
#' @import tidyr
#' @import data.tree
#' @import digest
NULL


## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
