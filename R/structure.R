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

  for (i in 1:nrow(event)) {
    e <- list(
      row = i,
      parentEventID = event$parentEventID[i],
      children = new.env(),
      measurements = new.env()
    )
    if ("eventRemarks" %in% names(event)) {
      e$eventRemarks <- event$eventRemarks[i]
    }
    register[[event$eventID[i]]] <- e
  }

  tree <- list(children = new.env())

  for (e in ls(register)) {
    parentEventID <- register[[e]]$parentEventID
    if (is.na(parentEventID)) {

      # top level event

      tree$children[[e]] <- register[[e]]

    } else {

      # not top level event

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

  # print

  printTree <- function(node) {
    for (key in ls(node$children)) {
      print(key)
      for (m in ls(node$children[[key]]$measurements)) {
        print(paste0("    ", m))
      }
      printTree(node$children[[key]])
    }
  }

  # add levels to tree

  depth <- 0

  addLevel <- function(children, level) {
    for (e in ls(children)) {
      if (depth < level) {
        depth <<- level
      }
      register[[e]]$level <- level
      addLevel(children[[e]]$children, level + 1)
    }
  }

  addLevel(tree$children, 1)

  # hash tree bottom up

  for (level in seq(depth, 1, by = -1)) {
    for (e in ls(register)) {
      if (register[[e]]$level == level) {

        identifiers <- c()

        # add measurement types to identifiers

        for (m in ls(register[[e]]$measurements)) {
          identifiers <- c(identifiers, m)
        }

        # add event remarks to identifiers

        if ("eventRemarks" %in% names(register[[e]])) {
          identifiers <- c(identifiers, register[[e]]$eventRemarks)
        }

        # add unique child hashes to identifiers

        for (n in ls(register[[e]]$children)) {
          hash <- register[[n]]$hash
          if (!hash %in% identifiers) {
            identifiers <- c(identifiers, hash)
          }
        }

        # collapse and hash identifiers

        if (length(identifiers) > 0) {
          identifiers <- sort(identifiers)
        }
        register[[e]]$hash <- md5(paste0(identifiers, collapse=";"))

      }
    }
  }

  # tree pruning

  prune <- function(children) {
    hashes <- new.env()
    for (n in ls(children)) {
      hash <- register[[n]]$hash
      if (!hash %in% ls(hashes)) {

        # hash occurs for first time

        hashes[[hash]] <- c(n)

      } else {

        # hash occurred before, remove from tree

        hashes[[hash]] <- c(hashes[[hash]], n)
        rm(list = c(n), envir = children)

      }

      # add counts

      for (h in ls(hashes)) {
        for (e in hashes[[h]]) {
          register[[e]]$count <- length(hashes[[h]])
        }
      }

      # prune children

      prune(register[[n]]$children)

    }
  }

  prune(tree$children)

  # output tree

  buildTree <- function(name, children) {
    result <- NULL
    for (e in ls(children)) {
      node <- list(name = e, count = register[[e]]$count, measurements = ls(register[[e]]$measurements))
      node$children <- buildTree(e, children[[e]]$children)
      result <- c(result, node)
    }
    return(result)
  }

  t <- buildTree("tree", tree$children)

  return(t)

}
