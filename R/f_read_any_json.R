#' @title Read a '.json' File in the '.pbix' Collection of Files
#' @description The byte sequence of a '.json' file within a '.pbix' is
#' retrieved, cleaned by removing ASCII control characters and written to
#' a temporary file. An attempt is made to read the temporary file as '.json'.
#' If reading the temporary file as '.json' fails, a second attempt is made.
#' For the second attempt, specific data within the '.json' file is included
#' and a temporary file is written. The temporary file is read as '.json'.
#' @author Don Diproto
#' @param input_file_pbix Path of the input '.pbix'.
#' @param input_file Path of '.json' file in collection of files.
#' @param gsub1 Text to select for replacement (i.e. text to exclude).
#' @param gsub2 Text to replace selected text (i.e. text to include).
#' @return Layout as '.json'.
#' @import jsonlite
#' @importFrom textclean replace_non_ascii
#' @importFrom stringr str_replace
#' @export
#' @seealso Uses: \code{\link{f_get_pbix_fir}}.
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
#' gsub__1 <- paste0(".*sections")
#' gsub__2 <- "\{\"id\":0,\"sections"
#' test <- f_read_any_json(pathFileSample, "Report/Layout",
#'                         gsub__1, gsub__2)
#'   }
f_read_any_json <- function(input_file_pbix, input_file, gsub1, gsub2) {
  buffer <- f_get_pbix_fir(input_file_pbix, input_file)

  # Remove any non-encoded characters ------------------------------------------
  # Convert raw to character representation
  buffer_char <- paste0("", buffer)

  # Create ASCII control characters for removal
  ascii_control_bytes <- (c())
  vec_ascii <- 1:33
  for (ascii_control_bytes_i in seq_along(vec_ascii)) {
    o1 <- as.character(as.hexmode(ascii_control_bytes_i - 1))
    o2 <- ifelse(nchar(o1) == 1, paste0(0, o1), o1)
    ascii_control_bytes[ascii_control_bytes_i] <- o2
  }

  control_byte_index <- which(buffer_char %in% ascii_control_bytes)

  if (length(control_byte_index) > 0) {
    clean_buffer_char <- buffer_char[-control_byte_index]
  } else {
    clean_buffer_char <- buffer_char
  }

  # Change the class back to raw
  clean_buffer <- as.raw(as.hexmode(clean_buffer_char))
  # Convert hex to characters
  clean_buffer_char <- rawToChar(clean_buffer, multiple = TRUE)
  # Make one long string remove non-ASCII characters
  clean_buffer_char_one <- textclean::replace_non_ascii(
    paste0(clean_buffer_char, collapse = "")
  )

  # Read the json --------------------------------------------------------------
  json_reader <- function(clean_buffer_char_one) {
    tryCatch({
        # Read without data exclusion
        temp_file <- tempfile()
        temp_file_new <- paste0(temp_file, ".json")
        zz <- file(temp_file, "wb")
        writeChar(clean_buffer_char_one, zz, eos = NULL)
        close(zz)
        file.rename(temp_file, temp_file_new)

        # Read
        get_data <- jsonlite::fromJSON(temp_file_new)
        return(get_data)
      },
      error = function(e) {
        # Read with data exclusion
        e_msg <- paste0(
          "An error occured reading without data exclusion. ",
          "The file was read with data exclusion: ",
          "gsub(\"", gsub1, "\"",
          ",\"", gsub2, "\", ...)"
        )
        message(e_msg)
        cb1 <- gsub(
          pattern = gsub1,
          replacement = gsub2,
          x = clean_buffer_char_one
        )

        temp_file <- tempfile()
        temp_file_new <- paste0(temp_file, ".json")
        zz <- file(temp_file, "wb")
        writeChar(cb1, zz, eos = NULL)
        close(zz)
        file.rename(temp_file, temp_file_new)

        # Read
        get_data <- jsonlite::fromJSON(temp_file_new)

        return(get_data)
      }
    )
  }

  read_json <- json_reader(clean_buffer_char_one)

  return(read_json)
}
