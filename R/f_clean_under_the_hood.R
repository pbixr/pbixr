#' @title Remove 'DataModel' from the Collection of Files Compressed in a
#' '.pbix'
#' @description '.pbix' is decompressed, making its collection of files
#' available for manipulation. 'DataModel' is removed from the collection.
#' Files remaining in the collection are (1) compressed to form a modified
#' '.pbix' and (2) deleted.
#' @author Don Diproto
#' @param input_file_pbix Path of the input '.pbix'.
#' @param collection_files_pbix Directory of the decompressed files
#' associated with the '.pbix'.
#' @param output_pbix Path of the modified '.pbix'.
#' @return None
#' @import formatR
#' @seealso Uses: \code{\link{f_remove_file}}.
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
#' pathFileSampleMod <- file.path(temp_dir, "sample_modified_f10.pbix")
#' dirFileSampleMod <- file.path(temp_dir, "sample_modified_f10")
#' # Remove output file and directory if they exist
#' if(file.exists(pathFileSampleMod)) {
#'   file.remove(pathFileSampleMod)
#' }
#' if(dir.exists(dirFileSampleMod)) {
#'   unlink(dirFileSampleMod, recursive = TRUE)
#' }
#' # Run the function
#' f_clean_under_the_hood(pathFileSample, dirFileSampleMod, pathFileSampleMod)
#'   }
f_clean_under_the_hood <- function(input_file_pbix, collection_files_pbix,
                                   output_pbix) {
  f_remove_file(input_file_pbix, collection_files_pbix, output_pbix,
                "DataModel")
}
