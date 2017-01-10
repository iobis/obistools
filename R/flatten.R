#' Flatten event records.
#'
#' @param event The event records.
#' @param fields Fields to be inherited from higher levels, if NULL all Event Core fields will be inherited.
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

#' Flatten event and occurrence records.
#'
#' @param event The event records.
#' @param event The occurrence records.
#' @param fields Fields to be inherited from the events, if NULL all Event Core fields will be inherited.
#' @return Flattened occurrence records.
#' @export
flatten_occurrence <- function(event, occurrence, fields = NULL) {

  # check occurrence eventIDs
  errors <- check_extension_eventids(event, occurrence)
  if (nrow(errors) > 0) {
    warning("Problem flattening records, use check_extension_eventids().")
    return(NULL)
  }

  # flatten events
  event <- flatten_event(event)
  if (is.null(event)) {
    return(NULL)
  }

  # determine which fields to inherit
  if (!is.null(fields)) {
    fields <- fields[which(fields %in% names(event))]
  } else {
    ef <- event_fields()
    fields <- ef[which(ef %in% names(event))]
    of <- occurrence_fields()
    fields <- fields[which(fields %in% of)]
  }
  fields <- fields[!fields %in% c("eventID", "parentEventID")]

  # create columns
  for (field in fields) {
    if (!field %in% names(occurrence)) {
      occurrence[[field]] <- NA
    }
  }

  # populate occurrences
  for (i in 1:nrow(occurrence)) {
    eventid <- occurrence$eventID[i]
    if (!is.na(eventid) & eventid != "") {
      occurrence_events <- event[event$eventID == eventid,]
      if (nrow(occurrence_events) == 1) {
        for (field in fields) {
          if (is.na(occurrence[[field]][i]) || occurrence[[field]][i] == "") {
            occurrence[[field]][i] <- occurrence_events[[field]][1]
          }
        }
      }
    }
  }

  return(occurrence)
}