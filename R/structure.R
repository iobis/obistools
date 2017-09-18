#' Generate a tree summarizing the dataset structure, based on measurement types and event remarks.
#'
#' @param event
#' @param measurement
#' @param identifier
#' @return
#' @export
treeStructure <- function(event, measurement, identifier) {

  require(tidyr)
  require(data.tree)
  require(dplyr)
  
  # events

  if ("occurrenceID" %in% names(measurement)) {
    measurement <- measurement %>% filter(is.na(occurrenceID))
  }
  measurement <- measurement %>% group_by(eventID) %>% summarize(types = paste0(sort(unique(measurementType)), collapse = ", "))
  if ("type" %in% names(event)) {
    event <- event %>% select(eventID, parentEventID, type)
  } else {
    event <- event %>% select(eventID, parentEventID)
  }

  event <- left_join(event,  measurement, by = "eventID")
  if ("type" %in% names(event)) {
    event <- unite(event, types, types, type, sep = ", ")
  }
  event$parentEventID[is.na(event$parentEventID)] <- "dummy_tree"
  event$types[is.na(event$types)] <- " "
  
  # clean up events
  
  parentids <- unique(event$parentEventID)
  event$leaf <- !event$eventID %in% parentids
  
  leafs <- event %>% filter(leaf) %>% group_by(parentEventID, types) %>% summarize(eventID = first(eventID), records = n())
  stems <- event %>% filter(!leaf) %>% mutate(records = 1)
  cleanevents <- bind_rows(stems, leafs) %>% select(-leaf) %>% arrange(eventID)

  # construct event tree

  eventtree <- FromDataFrameNetwork(cleanevents, check = "no-check")
  eventtree$types <- " "
  eventtree$records <- 0

  # construct summary tree

  paths <- eventtree$Get(function(node) { return(c(node$level, node$types, node$records)) }, simplify = FALSE)
  tree <- NULL
  history <- list()

  for (i in 1:length(paths)) {

    message(i)

    level <- as.integer(paths[i][[1]][1])
    types <- paths[i][[1]][2]
    records <- as.integer(paths[i][[1]][3])

    if (level <= length(history)) {
      for (j in level:length(history)) {
        history[[j]] <- NULL
      }
    }

    history[[level]] <- types

    if (level == 1) {
      tree <- Node$new(types)
    } else {

      # check if current path exists
      path <- unlist(history)[2:length(history)]
      result <- tree$Climb(name = path)

      if (is.null(result)) {
        # path does not exist, so go back one level
        if (length(path) > 1) {
          parent <- tree$Climb(name = head(path, -1))
        } else {
          parent <- tree
        }
        child <- parent$AddChild(types)
        child$records <- records
      } else {
        # exists, increase
        result$records <- result$records + records
      }
    }
  }
  
  return(tree)
  
}
