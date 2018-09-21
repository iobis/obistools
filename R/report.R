#' Creates a summary of a data quality report.
#'
#' @param qcreport QC errors report as created by merging results from
#'   \code{\link{check_fields}}, \code{\link{check_eventdate}},
#'   \code{\link{check_onland}}, \code{\link{check_depth}}, ...
#' @param maxrows Number of rows to return for each field.
#' @return A list with for each field that has errors or warnings the first
#'   \code{maxrows} number of records.
#' @export
report_summary <- function(qcreport, maxrows) {
  summary <- list()
  fields <- unique(qcreport$field)
  if(any(is.na(fields))) {
    fieldqc <- qcreport[is.na(qcreport$field), , drop = FALSE]
    summary[["General errors and warnings"]] <- fieldqc[1:min(nrow(fieldqc), maxrows), , drop = FALSE]
  }
  for(field in stats::na.omit(fields)) {
    fieldqc <- qcreport[!is.na(qcreport$field) & qcreport$field == field, , drop = FALSE]
    if(!all(fieldqc$level == 'debug')) {
      summary[[field]] <- fieldqc[1:min(nrow(fieldqc), maxrows), , drop = FALSE]
    }
  }
  return(summary)
}


#' Creates a basic data quality report.
#'
#' @param data The data frame.
#' @param qc QC errors, if not provided some tests are done on the provided
#'   data.
#' @param file Output file (default is "report.html").
#' @param dir Directory where to store the file (default is
#'   \code{rappdirs::user_cache_dir("obistools")}).
#' @param view Logical, show the report in a browser after creation (default
#'   \code{TRUE}).
#' @param topnspecies Integer, number of species ordered by number of records
#'   for which you want to do the outlier analysis
#' @return Returns the full path to the generated html report.
#' @examples
#' \dontrun{
#' report(abra)
#' }
#' @export
report <- function(data, qc = NULL, file = "report.html", dir = NULL, view = TRUE, topnspecies = 20) {

  reportfile <- system.file("", "report.Rmd", package = "obistools")

  if (is.null(qc)) {
    qc <- bind_rows(
      check_fields(data),
      check_eventdate(data),
      check_onland(data, report = TRUE),
      check_depth(data, report = TRUE),
      check_outliers_dataset(data, report = TRUE),
      check_outliers_species(data, report = TRUE, topn = topnspecies)
    )
    qc <- distinct(qc)
  }
  if(is.null(dir) || is.na(dir)) dir <- rappdirs::user_cache_dir("obistools")
  if(!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  outputfile <- rmarkdown::render(reportfile, output_file = file, output_dir = dir, params = list(data = data, qc = qc))
  if(view) {
    utils::browseURL(outputfile)
  }
  return(outputfile)
}
