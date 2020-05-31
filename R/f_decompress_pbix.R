#' @title Decompress '.pbix' to a Collection of Files
#' @description A '.pbix' is decompressed, making its collection of files
#' available for manipulation.
#' @author Don Diproto
#' @param input_file_pbix Path of the input '.pbix'.
#' @param collection_files_pbix Directory of the collection of files.
#' @return None
#' @import utils
#' @export
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
#' output_pbix_file <- gsub("OR_sample_func.pbix", "OR_unzip_pbix",
#' pathFileSample)
#' # Run the function
#' f_decompress_pbix(pathFileSample, output_pbix_file)
#'   }
f_decompress_pbix <- function(input_file_pbix, collection_files_pbix) {
  if (!file.exists(input_file_pbix)) {
    stop("Couldn't find .pbix: '", input_file_pbix, "'", call. = FALSE)
  }
  utils::unzip(input_file_pbix, list = FALSE,
                         exdir = collection_files_pbix)
}
