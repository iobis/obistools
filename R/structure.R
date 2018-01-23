#' Generate a tree summarizing the dataset structure, based on measurement types and event remarks.
#'
#' @param event Dataframe with events
#' @param occurrence Dataframe with occurrences
#' @param measurement Optional dataframe with measurements
#' @return a tree
#' @export
treeStructure <- function(event, occurrence, measurement = NULL) {

  # add columns and change IDs to character

  event$eventID <- as.character(event$eventID)
  if (!"parentEventID" %in% names(event)) {
    event$parentEventID <- NA
  }
  event$parentEventID <- as.character(event$parentEventID)
  occurrence$eventID <- as.character(occurrence$eventID)
  if (!is.null(measurement)) {
    measurement$eventID <- as.character(measurement$eventID)
  } else {
    measurement <- data.frame(eventID = character(), types = character(), stringsAsFactors = FALSE)
    omeasurement <- data.frame(occurrenceID = character(), eventID = character(), types = character(), stringsAsFactors = FALSE)
  }

  # measurements

  if (!is.null(measurement) && nrow(measurement) > 0) {

    if (!"occurrenceID" %in% names(measurement)) {
      measurement$occurrenceID <- NA
    }
    omeasurement <- measurement %>% filter(!is.na(occurrenceID))
    measurement <- measurement %>% filter(is.na(occurrenceID) | occurrenceID == "")

    # event measurements

    measurement <- measurement %>% group_by(eventID) %>% summarize(types = paste0(sort(unique(measurementType)), collapse = ", "))

    # occurrence measurements

    omeasurement <- omeasurement %>% group_by(occurrenceID) %>% summarize(types = paste0(sort(unique(measurementType)), collapse = ", ")) %>% select(eventID = occurrenceID, types = types)
    omeasurement$eventID <- paste0("occurrence#", omeasurement$eventID)

  }

  # events

  if ("type" %in% names(event)) {
    event <- event %>% select(eventID, parentEventID, type)
  } else {
    event <- event %>% select(eventID, parentEventID)
    event$type <- ""
  }

  event <- left_join(event, measurement, by = "eventID")
  event$parentEventID[is.na(event$parentEventID)] <- "dummy"
  event$types[is.na(event$types)] <- ""
  event$type[is.na(event$type)] <- ""
  event$occurrence <- FALSE

  # occurrence dummy events

  oevent <- occurrence %>% select(eventID = occurrenceID, parentEventID = eventID)
  oevent$eventID <- paste0("occurrence#", oevent$eventID)
  oevent <- left_join(oevent, omeasurement, by = "eventID")
  oevent$types[is.na(oevent$types)] <- ""
  oevent$type <- ""
  oevent$occurrence <- TRUE

  # merge

  event <- bind_rows(event, oevent)

  # clean up events

  parentids <- unique(event$parentEventID)
  event$leaf <- !event$eventID %in% parentids

  if ("type" %in% names(event)) {
    leafs <- event %>% filter(leaf) %>% group_by(parentEventID, types, occurrence, type) %>% summarize(eventID = first(eventID), records = n())
  } else {
    leafs <- event %>% filter(leaf) %>% group_by(parentEventID, types, occurrence) %>% summarize(eventID = first(eventID), records = n())
  }
  stems <- event %>% filter(!leaf) %>% mutate(records = 1)
  cleanevents <- bind_rows(stems, leafs) %>% select(-leaf) %>% arrange(eventID)

  # hash events

  cleanevents$hash <- NA

  for (i in 1:nrow(cleanevents)) {
    types <- cleanevents$types[i]
    if ("type" %in% names(cleanevents)) {
      types <- paste0(types, cleanevents$type[i], collapse = ";")
    }
    hash <- digest(types, algo = "sha1")
    cleanevents$hash[i] <- hash
  }

  if ("type" %in% names(cleanevents)) {
    cleanevents <- cleanevents %>% select(c("eventID", "parentEventID", "records", "hash", "occurrence", "type", "types"))
  } else {
    cleanevents <- cleanevents %>% select(c("eventID", "parentEventID", "records", "hash", "occurrence", "types"))
  }

  # construct event tree

  eventtree <- FromDataFrameNetwork(cleanevents, check = "check")
  eventtree$hash <- " "
  eventtree$records <- 0

  # construct summary tree

  paths <- eventtree$Get(function(node) { return(c(node$level, node$hash, node$records, node$occurrence, node$type, node$types)) }, simplify = FALSE)
  tree <- NULL
  history <- list()

  for (i in 1:length(paths)) {

    level <- as.integer(paths[i][[1]][1])
    hash <- paths[i][[1]][2]
    records <- as.integer(paths[i][[1]][3])
    isoccurrence <- as.logical(paths[i][[1]][4])
    example <- names(paths[i])
    type <- paths[i][[1]][5]
    types <- paths[i][[1]][6]

    # reconstruct complete path
    if (level <= length(history)) {
      for (j in seq(length(history), level, by = -1)) {
        history[[j]] <- NULL
      }
    }
    history[[level]] <- hash

    if (level == 1) {
      tree <- Node$new(hash)
    } else {

      # check if current path exists
      path <- unlist(history)[2:length(history)]
      result <- tree$Climb(name = path)

      if (is.null(result)) {
        # path does not exist, so go back one level
        if (length(path) > 1) {
          parent <- tree$Climb(name = utils::head(path, -1))
        } else {
          parent <- tree
        }
        child <- parent$AddChild(hash)
        child$records <- records
        child$example <- example
        child$occurrence <- isoccurrence
        child$type <- type
        child$types <- types
      } else {
        # exists, increase
        result$records <- result$records + records
      }
    }
  }

  return(tree)

}

#' Exports a visual representation of a tree to an HTML file.
#'
#' @param tree tree as generated by \code{\link{treeStructure}}
#' @param filename output html file name
#' @param view logical. If \code{TRUE} (default) then the tree structure is opened in a
#'   browser
#' @export
exportTree <- function(tree, filename, view=TRUE) {
  text <- "<!doctype html>\n<html>\n<head>\n<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\">\n<style>\nul {\n  list-style-type: none;\n}\n.btn-occurrence {\n  background-color: #EAEFD3;\n}\n.btn {\n  cursor: default;\n}\n.btn {\n  margin: 2px 0px;\n}\n.btn-event {\n  background-color: #FCECC9;\n}\n.container {\n  padding-top: 20px;\n}\n.details {\n  padding-left: 30px;\n  font-size: 0.7em;\n}\n</style>\n</head>\n<body>\n<div class=\"container\">\n<div class=\"row\">\n<ul>\nplaceholder\n</ul>\n</div>\n</div>\n</body>\n</html>\n"
  fragments <- NULL

  append <- function(fragment) {
    fragments <<- c(fragments, fragment)
  }

  out <- function(node) {
    append("<li>")
    if ("occurrence" %in% names(node) && node$occurrence) {
      append("<span class=\"btn btn-xs btn-occurrence\">")
    } else {
      append("<span class=\"btn btn-xs btn-event\">")
    }
    append(sub("^occurrence#", "", node$example))
    append("</span>")
    append(paste0("<span class=\"btn btn-xs btn-records\">", node$records, "</span>", sep = ""))
    append("<div class=\"details\">")

    extras <- NULL
    if (!is.na(node$type) & node$type != "") {
      extras <- c(extras, paste0("event type: ", node$type, sep = ""))
    }
    if (!is.na(node$types) & node$types != "") {
      extras <- c(extras, paste0("measurement types: ", node$types, sep = ""))
    }
    if (length(extras) > 0) {
      append(paste0(extras, collapse = "<br/>"))
    }
    append("</div>")
    append("<ul>")
    sapply(node$children, out)
    append("</ul>")
    append("</li>")
  }
  out(tree$children[[1]])

  result <- sub("placeholder", paste0(fragments, collapse = ""), text)
  write(result, file = filename)
  if(view) {
    utils::browseURL(filename)
  }
}
