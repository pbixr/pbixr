#' @title Get Details of an '.xml' within 'DataMashup'
#' @description The details of an '.xml' within 'DataMashup' are retrieved.
#' @author Don Diproto
#' @param input_file_pbix Path of the input '.pbix'.
#' @return A list containing [[1]] the length of each '.xml', [[2]] the first
#' 400 bytes of each '.xml' converted to character and [[3]] the total length of
#' all '.xml' files.
#' @import stringr
#' @export
#' @seealso Uses: \code{\link{f_get_dama_index}},
#' \code{\link{f_get_dama_file}},
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
#' # Run the function
#' test <- f_get_dama_xml_details(pathFileSample)
#'   }
f_get_dama_xml_details <- function(input_file_pbix) {
  index_collection <- f_get_dama_index(input_file_pbix)
  extract_xml <- f_get_dama_file(input_file_pbix, "xml", index_collection)

  # Find all XML files ---------------------------------------------------------
  xml_start_1 <- paste0(charToRaw("<?xml version="), collapse = "")
  extract_xml_str <- paste0(extract_xml, collapse = "")
  locate_start <- stringr::str_locate_all(extract_xml_str, xml_start_1)

  # Show XML start -------------------------------------------------------------
  list_loop <- list()
  for (xml_i in seq_len(nrow(locate_start[[1]]))) {
    xml_start <- as.numeric(locate_start[[1]][xml_i, 1])
    o1 <- substr(extract_xml_str, xml_start, xml_start + 399)
    o2  <- vapply(seq(1, nchar(as.character(o1)), by = 2), function(x)
      substr(o1, x, x + 1), character(1))
    list_cy <- c()
    for (xml_y in seq_along(seq_along(o2))) {
      list_cy[xml_y] <- rawToChar(as.raw(paste0("0x", o2[xml_y])))
    }
    list_loop[[xml_i]] <- paste0(list_cy, collapse = "")
  }
  xml_headers <- unlist(list_loop)

  # Show XML length ------------------------------------------------------------
  all_xml_length <- length(extract_xml)
  xml_start_posi <- locate_start[[1]][, 1]
  indi_xml_length <- c(diff(xml_start_posi), all_xml_length -
                         xml_start_posi[2:length(xml_start_posi)])

  # Return length and header ---------------------------------------------------
  output <- list("length" = indi_xml_length,
                 "xml_start" = xml_headers,
                 "xml_length" = length(extract_xml))
  return(output)
}
