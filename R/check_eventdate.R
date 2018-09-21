check_date <- function(date) {
  pattern <- "^\\d{4}(-\\d{2}(-\\d{2}([T|\\s]\\d{2}(:\\d{2}(:\\d{2})?)?(Z|([+-]\\d{2}:?(\\d{2})?))?)?)?)?$"

  if (!is.na(date) & date != "") {

    # split date in start end end parts
    parts <- str_split(date, "/")[[1]]

    # check if date is single date
    if (length(parts) == 1) {

      return(!is.na(str_match(parts[1], pattern)[1]))

      # check if date is interval
    } else if (length(parts) == 2) {

      start <- parts[1]
      end <- parts[2]

      # check if both start and end dates match
      if (!is.na(str_match(start, pattern)[1]) & !is.na(str_match(end, pattern)[1])) {

        return(TRUE)

        # check if start date matches and end date is shorter than start date
      } else if (!is.na(str_match(start, pattern)[1]) & nchar(end) < nchar(start)) {

        # use start date to complete end date
        newend <- paste0(substr(start, 1, nchar(start) - nchar(end)), end)
        return(!is.na(str_match(newend, pattern)[1]))

      }
    }
  }
  return(FALSE)
}

#' Check eventDate format.
#'
#' @param data The data frame.
#' @return Any errors.
#' @export
check_eventdate <- function(data) {

  if (!"eventDate" %in% names(data)) {
    return(data_frame(
      level = "error",
      message = "Column eventDate missing"
    ))
  }

  rows <- which(!vapply(as.character(data$eventDate), check_date, logical(1), USE.NAMES = FALSE))

  if (length(rows) == 0) {
    return(data_frame())
  } else {
    return(data_frame(
      level = "error",
      row = rows,
      field = "eventDate",
      message = paste0("eventDate ", data$eventDate[rows], " does not seem to be a valid date")
    ))
  }

}
