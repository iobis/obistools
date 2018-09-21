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

    errors <- data_frame()
    required <- c("eventDate", "decimalLongitude", "decimalLatitude", "scientificName", "scientificNameID", "occurrenceStatus", "basisOfRecord")
    recommended <- c("minimumDepthInMeters", "maximumDepthInMeters")

    # find missing required fields

    fields <- missing_fields(data, required)
    if (length(fields) > 0) {
      errors <- bind_rows(errors, data_frame(
        level = "error",
        field = fields,
        row = NA,
        message = paste0("Required field ", fields, " is missing")
      ))
    }

    # find empty values for required fields

    for (field in required) {
      if (field %in% names(data)) {
        rows <- missing_values(data[,field])
        if (length(which(rows)) > 0) {
          errors <- bind_rows(errors, data_frame(
            level = "error",
            field = field,
            row = which(rows),
            message = paste0("Empty value for required field ", field)
          ))
        }
      }
    }

    # recommended fields

    if (level == "warning") {

      # find missing recommended fields

      fields <- missing_fields(data, recommended)
      if (length(fields) > 0) {
        errors <- bind_rows(errors, data_frame(
          field = fields,
          level = "warning",
          message = paste0("Recommended field ", fields, " is missing")
        ))
      }

      # find empty values for recommended fields

      for (field in recommended) {
        if (field %in% names(data)) {
          rows <- missing_values(data[,field])
          if (length(which(rows)) > 0) {
            errors <- bind_rows(errors, data_frame(
              level = "warning",
              field = field,
              row = which(rows),
              message = paste0("Empty value for recommended field ", field)
            ))
          }
        }
      }

    }

    return(errors)
}
