#' Map column names.
#'
#' @param data The data frame.
#' @param mapping The mapping as a list.
#' @return The data frame with mapped column names.
#' @export
map_fields <- function(data, mapping) {
  i <- match(names(data), mapping)
  new <- names(mapping)[i]
  new[is.na(new)] <- names(data[is.na(new)])
  colnames(data) <- new
  return(data)
}
