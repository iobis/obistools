#' Check if eventID and parentEventID are present, and parentEventIDs have corresponding eventIDs.
#'
#' @param event The event records.
#' @return Any errors.
#' @export
check_eventids <- function(event) {

  errors <- data.frame()

  # check presence of eventID and parentEventID

  fields <- missing_fields(event, c("eventID", "parentEventID"))

  if (length(fields) > 0) {
    return(data.frame(
      field = fields,
      level = "error",
      message = paste0("Field ", fields, " is missing"),
      stringsAsFactors = FALSE
    ))
  }

  # ids

  eventIDs <- event$eventID[!is.na(event$eventID) & !event$eventID == ""]
  parentEventIDs <- event$parentEventID[!is.na(event$parentEventID) & !event$parentEventID == ""]

  # check duplicate eventIDs

  rows <- which(duplicated(eventIDs))

  if (length(rows) > 0) {
    errors <- bind_rows(errors, data.frame(
      field = "eventID",
      level = "error",
      row = rows,
      message = paste0("eventID ", event$eventID[rows], " is duplicated"),
      stringsAsFactors = FALSE
    ))
  }

  # check if all parentEventIDs have corresponding eventID

  missing_ids <- parentEventIDs[which(!(parentEventIDs %in% eventIDs))]
  rows <- which(event$parentEventID %in% missing_ids)

  if (length(rows) > 0) {
    errors <- bind_rows(errors, data.frame(
      field = "parentEventID",
      level = "error",
      row = rows,
      message = paste0("parentEventID ", event$parentEventID[rows], " has no corresponding eventID"),
      stringsAsFactors = FALSE
    ))
  }

  return(errors)
}
