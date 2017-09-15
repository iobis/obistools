#' Generate a tree summarizing the dataset structure, based on measurement types and event remarks.
#'
#' @param event
#' @param measurement
#' @param identifier
#' @return
#' @export
treeStructure <- function(event, measurement, identifier = "measurementType") {

  # create event tree

  register <- new.env()
  tree <- list(children = new.env())

  for (i in 1:nrow(event)) {
    e <- list(
      row = i,
      parentEventID = event$parentEventID[i],
      children = new.env(),
      measurements = new.env()
    )
    if ("type" %in% names(event)) {
      e$type <- event$type[i]
    }
    register[[event$eventID[i]]] <- e
  }

  for (e in ls(register)) {
    parentEventID <- register[[e]]$parentEventID
    if (is.na(parentEventID)) {
      tree$children[[e]] <- register[[e]]
    } else {
      parent <- register[[parentEventID]]
      parent$children[[e]] <- register[[e]]
    }
  }

  # add measurements

  for (m in 1:nrow(measurement)) {
    eventID <- measurement$eventID[m]
    type <- measurement[m, identifier]
    register[[eventID]]$measurements[[type]] <- TRUE
  }

  # hash all nodes

  for (e in ls(register)) {

    # add measurement types to identifiers
    identifiers <- ls(register[[e]]$measurements)

    # add type to identifiers
    if ("type" %in% names(register[[e]])) {
      identifiers <- c(identifiers, register[[e]]$type)
    }
  }

  if (length(identifiers) > 0) {
    identifiers <- sort(identifiers)
  }

  register[[e]]$hash <- md5(paste0(identifiers, collapse=";"))

  # ...


  }
