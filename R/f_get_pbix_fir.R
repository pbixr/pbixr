#' @title Get the Byte Sequence of a File from the Collection of Files Compress
#' ed in a '.pbix'
#' @description '.pbix' is decompressed in memory, making its collection of
#' files available for manipulation. The byte sequence of a specific file
#' in the collection is retained. Files in the collection can be identified
#' with f_get_pbix_info.
#' @author Don Diproto
#' @param input_file_pbix Path of the input '.pbix'.
#' @param variable Name of file in the collection of files.
#' @return Byte sequence of a file.
#' @import  utils
#' @export
#' @note f_get_pbix_fir included modification of a function ('zip_buffer')
#' from the 'readxl' package (licence GPL-3). The function could not be
#' imported from readxl at the time of 'pbixr' publication.
#' 'zip_buffer' was available from:
#' \url{https://github.com/tidyverse/readxl/blob/master/R/xlsx-zip.R}.
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
#' variable <-  paste0("Report/CustomVisuals/ImgViewerVisual1455487926945/",
#' "resources/ImgViewerVisual.css")
#' # Run the function
#' test <- f_get_pbix_fir(pathFileSample, variable)
#'   }
f_get_pbix_fir <- function(input_file_pbix, variable) {
  if (!file.exists(input_file_pbix)) {
    error_message <- paste0("Couldn't find .pbix: '", input_file_pbix, "'.")
    stop(error_message, call. = FALSE)
  }

  zip_buffer <- function(zip_path, file_path) {
    files <- utils::unzip(zip_path, list = TRUE)

    indx <- match(file_path, files$Name)
    if (is.na(indx)) {
      error_message <- paste0("Couldn't find '", variable, "'. Consider using
    f_get_pbix_info to name all  files in the compressed file.")
      stop(error_message, call. = FALSE)
    }

    size <- files$Length[indx]

    con <- unz(zip_path, file_path, open = "rb")
    on.exit(close(con), add = TRUE)
    readBin(con, raw(), n = size)
  }
  buffer <- zip_buffer(input_file_pbix, variable)
  return(buffer)
}
