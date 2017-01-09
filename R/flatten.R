#' Flatten event records.
#'
#' @param event The event records.
#' @param fields Fields to be inherited from higher levels, if NULL all fields will be inherited.
#' @return Flattened event records.
#' @export
flatten_event <- function(event, fields = NULL) {

  # check eventIDs

  errors <- check_eventids(event)

  if (nrow(errors) > 0) {
    warning("Problem flattening records, use check_eventids().")
    return(NULL)
  }

  # determine which fields to inherit

  if (!is.null(fields)) {
    fields <- fields[which(fields %in% names(event))]
  } else {
    ef <- event_fields()
    fields <- ef[which(ef %in% names(event))]
  }

  fields <- fields[!fields %in% c("eventID", "parentEventID")]

  # process events

  processed <- NULL

  while (TRUE) {

    move <- NULL

    for (i in 1:nrow(event)) {

      # check if event has parent

      if (is.na(event$parentEventID[i]) || event$parentEventID[i] == "") {
        move <- c(move, i)
      }

      # check if event has parent event in processed list

      parent <- which(event$parentEventID[i] == processed$eventID)

      if (length(parent) == 1) {

        # populate fields

        for (field in fields) {
          if (is.na(event[[field]][i]) || event[[field]][i] == "") {
            event[[field]][i] <- processed[[field]][parent]
          }
        }

        # tag as processed

        move <- c(move, i)

      }

    }

    if (length(move) == 0) {
      break
    }

    # move records

    processed <- bind_rows(processed, event[move,])
    event <- event[-move,]

    if (nrow(event) == 0) {
      break
    }

  }

  return(processed)

}
