#' @title Identify Collection of Files Compressed in '.pbix'
#' @description '.pbix' is decompressed in memory, making names and properties
#' (length, date) of files in collection available.
#' @author Don Diproto
#' @param input_file_pbix Path of the input ''.pbix''.
#' @return data.frame: Names, lengths (kb) and dates associated with collection
#'  of files in '.pbix'.
#' @import utils
#' @export
#' @examples
#' \dontrun{
#' # Create a temporary directory
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
#' test <- f_get_pbix_info(pathFileSample)
#'   }
f_get_pbix_info <- function(input_file_pbix) {
  if (!file.exists(input_file_pbix)) {
    stop("Couldn't find .pbix: '", input_file_pbix, "'", call. = FALSE)
  }
  output <- utils::unzip(input_file_pbix, list = TRUE)
  return(output)
}
