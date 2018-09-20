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
    stop("Problem flattening records, use check_eventids().")
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
#' @param occurrence The occurrence records.
#' @param field The eventID field name in the extension records.
#' @param fields Fields to be inherited from the events, if NULL all Event Core fields will be inherited.
#' @return Flattened occurrence records.
#' @export
flatten_occurrence <- function(event, occurrence, field = "eventID", fields = NULL) {

  # check occurrence eventIDs
  errors <- check_extension_eventids(event, occurrence)
  if (nrow(errors) > 0) {
    stop("Problem flattening records, use check_extension_eventids().")
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
  for (f in fields) {
    if (!f %in% names(occurrence)) {
      occurrence[[f]] <- NA
    }
  }

  # populate occurrences
  for (f in fields) {
    if (!f %in% names(occurrence)) {
      occurrence[[f]] <- NA
    }
  }
  eventid <- occurrence[[field]]
  missing_eventid <- is.na(eventid) | eventid == ""
  occurrence_events <- event[event$eventID %in% eventid[!missing_eventid],]
  nonunique_events <- unique(occurrence_events$eventID[duplicated(occurrence_events$eventID)])
  unique_occurrence_events <- occurrence_events[!(occurrence_events$eventID %in% nonunique_events),]
  occindices <- occurrence[[field]] %in% unique_occurrence_events$eventID
  eventindices <- match(occurrence[occindices,field], unique_occurrence_events$eventID)
  for(f in fields) {
    occurrence[occindices,f] <- unique_occurrence_events[eventindices,f]
  }

  return(occurrence)
}
