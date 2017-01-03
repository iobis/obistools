#' Check if the required and recommended OBIS fields are present.
#'
#' Missing or empty required fields are reported as errors,
#' missing or empty recommended fields are reported as warnings.
#'
#' @param data The data frame.
#' @param level The level of error reporting, i.e. "error" or "warning". Recommended fields are only checked in case of "warning".
#' @return Any warnings or errors.
#' @export
check_fields <- function(data, level = "error") {

    errors <- NULL
    required <- c("eventDate", "decimalLongitude", "decimalLatitude", "scientificName", "scientificNameID", "occurrenceStatus", "basisOfRecord")
    recommended <- c("minimumDepthInMeters", "maximumDepthInMeters")

    # find missing required fields

    fields <- missing_fields(data, required)
    errors <- bind_rows(errors, data.frame(
      field = fields,
      level = "error",
      message = paste0("Required field ", fields, " is missing"),
      stringsAsFactors = FALSE
    ))

    # find empty values for required fields

    for (field in required) {
      if (field %in% names(data)) {
        rows <- missing_values(data[,field])
        errors <- bind_rows(errors, data.frame(
          level = "error",
          field = field,
          row = which(rows),
          message = paste0("Empty value for required field ", field),
          stringsAsFactors = FALSE
        ))
      }
    }

    # recommended fields

    if (level == "warning") {

      # find missing recommended fields

      fields <- missing_fields(data, recommended)
      errors <- bind_rows(errors, data.frame(
        field = fields,
        level = "warning",
        message = paste0("Recommended field ", fields, " is missing"),
        stringsAsFactors = FALSE
      ))

      # find empty values for recommended fields

      for (field in recommended) {
        if (field %in% names(data)) {
          rows <- missing_values(data[,field])
          errors <- bind_rows(errors, data.frame(
            level = "warning",
            field = field,
            row = which(rows),
            message = paste0("Empty value for recommended field ", field),
            stringsAsFactors = FALSE
          ))
        }
      }

    }

    return(errors)

}

missing_fields <- function(data, fields) {
  missing <- !(fields %in% names(data))
  return(fields[missing])
}

missing_values <- function(data) {
  return(data %in% c(NA, ""))
}
