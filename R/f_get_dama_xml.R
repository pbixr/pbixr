#' @title Get '.xml' within 'DataMashup'
#' @description The byte sequence of 'DataMashup' within a '.pbix' is
#' retrieved and the '.xml' is extracted.
#' @author Don Diproto
#' @param input_file_pbix Path of the input '.pbix'.
#' @param xml_start Start position of '.xml'
#' @param xml_end End position of '.xml'
#' @return The '.xml' Within 'DataMashup'.
#' @import xml2
#' @export
#' @seealso Uses: \code{\link{f_get_dama_index}},
#' \code{\link{f_get_dama_file}}.
#' @examples
#' \dontrun{
#' # Get dummy data ------------------------------------------------------------
#' # Create a temporary directory
#' temp_dir <- file.path(tempdir(),"functionTest")
#' if(!dir.exists(temp_dir)) {
#' 	dir.create(temp_dir)
#' }
#' sample_file_name <- "OR_sample_func.pbix"
#' pathFileSample <- file.path(temp_dir, sample_file_name)
#'
#' # See if dummy data already exists in temporary directory
#' parent_temp_dir <- dirname(temp_dir)
#' existing_file <- list.files(parent_temp_dir,
#' pattern = sample_file_name, recursive = TRUE, full.names = TRUE)
#'
#' # Download the sample .pbix if it doesn't exist
#' if (length(existing_file) == 0) {
#'    url_pt1 <- "https://github.com/KoenVerbeeck/PowerBI-Course/blob/"
#'    url_pt2 <- "master/pbix/TopMovies.pbix?raw=true"
#'    url <- paste0(url_pt1, url_pt2)
#'    req <- download.file(url, destfile = pathFileSample, mode = "wb")
#' } else {
#'    pathFileSample <- existing_file[1]
#' }
#' # Do stuff ------------------------------------------------------------------
#'
#' # Get the start and end positions
#' test <- f_get_dama_xml_details(pathFileSample)
#' xml_start <- (test[[1]][1]/2) + 1
#' xml_end <- test[[3]][1]
#' # Run the function
#' output <- f_get_dama_xml(pathFileSample, xml_start, xml_end)
#'   }
f_get_dama_xml <- function(input_file_pbix, xml_start, xml_end) {
  index_collection <- f_get_dama_index(input_file_pbix)
  extract_xml <- f_get_dama_file(input_file_pbix, "xml", index_collection)

  # Get XML files --------------------------------------------------------------
  if (xml_start > index_collection[[4]]) {
    error_message <- paste0("Start position exceeds length of the XML.")
    stop(error_message, call. = FALSE)
  }
  if (xml_end > index_collection[[4]]) {
    error_message <- paste0("End position exceeds length of the XML.")
    stop(error_message, call. = FALSE)
  }
  xml_subset <- extract_xml[xml_start:xml_end]

  # Write XML file -------------------------------------------------------------
  temp_file <- tempfile()
  con <- file(temp_file, "wb")
  end_loop <- length(xml_subset)
  for (xml_si in seq_along(1:end_loop)) {
    write_value <- xml_subset[xml_si]
    writeBin(write_value, con = con)
  }
  close(con)

  # Read XML file --------------------------------------------------------------
  xml_read <- xml2::read_xml(temp_file)

  file.remove(temp_file)

  return(xml_read)
}
