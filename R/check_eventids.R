#' Check if eventID and parentEventID are present, and parentEventIDs have corresponding eventIDs.
#'
#' @param event The event records.
#' @return Any errors.
#' @export
check_eventids <- function(event) {

  errors <- data_frame()

  # check presence of eventID and parentEventID

  fields <- missing_fields(event, c("eventID", "parentEventID"))

  if (length(fields) > 0) {
    return(data_frame(
      field = fields,
      level = "error",
      message = paste0("Field ", fields, " is missing")
    ))
  }

  # ids

  eventIDs <- event$eventID[!is.na(event$eventID) & !event$eventID == ""]
  parentEventIDs <- event$parentEventID[!is.na(event$parentEventID) & !event$parentEventID == ""]

  # check duplicate eventIDs

  rows <- which(duplicated(eventIDs))

  if (length(rows) > 0) {
    errors <- bind_rows(errors, data_frame(
      field = "eventID",
      level = "error",
      row = rows,
      message = paste0("eventID ", event$eventID[rows], " is duplicated")
    ))
  }

  # check if all parentEventIDs have corresponding eventID

  missing_ids <- parentEventIDs[which(!(parentEventIDs %in% eventIDs))]
  rows <- which(event$parentEventID %in% missing_ids)

  if (length(rows) > 0) {
    errors <- bind_rows(errors, data_frame(
      field = "parentEventID",
      level = "error",
      row = rows,
      message = paste0("parentEventID ", event$parentEventID[rows], " has no corresponding eventID")
    ))
  }

  return(errors)
}

#' Check if all eventIDs in an extension have corresponding eventIDs in the core.
#'
#' @param event The event records.
#' @param extension The extension records.
#' @param field The eventID field name in the extension records.
#' @return Any errors.
#' @export
check_extension_eventids <- function(event, extension, field = "eventID") {
  rows <- which(!extension[[field]] %in% event$eventID)
  if (length(rows) > 0) {
    return(data.frame(
      field = field,
      level = "error",
      row = rows,
      message = paste0(field, " ", extension[[field]][rows], " has no corresponding eventID in the core"),
      stringsAsFactors = FALSE
    ))
  } else {
    return(data_frame())
  }
}
