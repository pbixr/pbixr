#' @title Get 'Power Query M' Formula within 'DataMashup'
#' @description The byte sequence of 'DataMashup' within '.pbix' is retrieved
#' and the 'Power Query M' formula is extracted.
#' @author Don Diproto
#' @param input_file_pbix Path of the input '.pbix'.
#' @param remove_temp Option to remove temporary zip file.
#' @return 'Power Query M' formula.
#' @import utils
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
#' # Run the function
#' test <- f_get_dama_m(pathFileSample, TRUE)
#'   }
f_get_dama_m <- function(input_file_pbix, remove_temp) {
  # Get zip files --------------------------------------------------------------
  index_collection <- f_get_dama_index(input_file_pbix)
  extract_zip <- f_get_dama_file(input_file_pbix, "ziponly", index_collection)

  # Write compressed files -----------------------------------------------------
  temp_file <- paste0(tempfile(), ".zip")
  con <- file(temp_file, "wb")
  end_loop <- length(extract_zip)
  for (xml_si in seq_along(1:end_loop)) {
    write_value <- extract_zip[xml_si]
    writeBin(write_value, con = con)
  }
  close(con)

  # Decompress M file ----------------------------------------------------------
  temp_file2 <- paste0(tempfile())
  utils::unzip(temp_file, list = FALSE,
                         exdir = temp_file2)
  con <- file(file.path(temp_file2, "Formulas", "Section1.m"), "rt")
  output <- readLines(con, warn = FALSE)
  close(con)

  # Remove files ---------------------------------------------------------------
  if (remove_temp == TRUE) {
    if (file.exists(temp_file)) {
      file.remove(temp_file)
    }

    if (dir.exists(temp_file2)) {
      unlink(temp_file2)
    }
  }

  return(output)
}
