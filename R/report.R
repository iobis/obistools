#' Creates a basic data quality report.
#'
#' @param data The data frame.
#' @param qc QC errors, if not provided some tests are done on the provided data.
#' @param file Output file.
#' @export
report <- function(data, qc = NULL, file = "report.html") {

  reportfile <- system.file("", "report.Rmd", package = "obistools")

  if (is.null(qc)) {
    qc <- bind_rows(
      check_fields(data),
      check_eventdate(data),
      check_onland(data, report = TRUE)
    )
  }

  render(reportfile, output_file = file, output_dir = getwd(), params = list(data = data, qc = qc))

}
