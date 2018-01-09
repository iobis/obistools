#' Map column names.
#'
#' @param data The data frame.
#' @param mapping The mapping as a list.
#' @return The data frame with mapped column names.
#' @examples
#' map_fields(data.frame(x=1:3, y=4:6),
#'            list(decimalLongitude="x", decimalLatitude="y"))
#' @export
map_fields <- function(data, mapping) {
  i <- match(names(data), mapping)
  new <- names(mapping)[i]
  new[is.na(new)] <- names(data[is.na(new)])
  colnames(data) <- new
  return(data)
}
