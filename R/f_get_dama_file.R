#' @title Get a File within 'DataMashup'
#' @description The byte sequence of 'DataMashup' within a '.pbix' is retrieved
#' and the relevant file within 'DataMashup' is extracted.
#' @author Don Diproto
#' @param input_file_pbix Path of the input '.pbix'.
#' @param variable File to be extracted ("xml", "zip", "ziponly" or "hf"). "xml"
#' refers to one or more uncompressed '.xml' files inside 'DataMashup'. "zip"
#' refers to compressed ('.zip') data within 'DataMashup'.  "ziponly" refers to
#' "zip" excluding "xml". "hf" refers to data occuring before and
#' after compressed data.
#' @param index_collection Index created with f_get_dama_index.
#' @return The byte sequnce of 'DataMashup' based on an index.
#' @export
#' @seealso Uses: \code{\link{f_get_dama}}.
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
#' index_collection <- f_get_dama_index(pathFileSample)
#' # Run the function with different options
#' # xml
#' test_xml <- f_get_dama_file(pathFileSample, "xml", index_collection)
#' # zip
#' test_zip <- f_get_dama_file(pathFileSample, "zip", index_collection)
#' # ziponly
#' test_zip <- f_get_dama_file(pathFileSample, "ziponly", index_collection)
#' # hf
#' test_hf <- f_get_dama_file(pathFileSample, "hf", index_collection)
#'   }
f_get_dama_file <- function(input_file_pbix, variable, index_collection) {
  # Identify relevant index ----------------------------------------------------
  if (variable == "xml") {
    get_index <- index_collection[[3]]
  } else {
    if (variable == "zip") {
      get_index <- index_collection[[1]]
    } else {
      if (variable == "hf") {
        get_index <- list(c(1, index_collection[[1]][1] - 1),
                          c(index_collection[[1]][2] + 1,
                            index_collection[[4]]))
      } else {
        if (variable == "ziponly") {
          zip_index <- index_collection[[1]]
          zip_sequence <- zip_index[1]:zip_index[2]
          # Remove xml
          xml_index <- index_collection[[3]]
          xml_sequence_to_remove <- xml_index[1]:xml_index[2]
          zip_sequence_clean_id <- which((zip_sequence %in%
                                        xml_sequence_to_remove) == FALSE)
          get_index <- zip_sequence[zip_sequence_clean_id]
          rm(zip_sequence_clean_id); rm(xml_sequence_to_remove);
          rm(xml_index); rm(zip_sequence); rm(zip_index)
        } else {
          error_message <- paste0(
            "Variable (", input_file_pbix, ") is not ", 
            " recognised. Use 'xml', 'zip', ", 
            "'ziponly' or 'hf'."
            )
          stop(error_message, call. = FALSE)
        }
      }
    }
  }
  index_to_use <- get_index

  # Extract DataMashup ---------------------------------------------------------
  buffer <- f_get_dama(input_file_pbix)

  # Pull out relevant part based on index --------------------------------------
  # Differentiate because "hf" returns two obects; the other variables, one.
  if (variable != "hf") {
    if (variable == "ziponly") {
      output <- buffer[index_to_use]
    }
    if (variable != "ziponly") {
      output <- buffer[index_to_use[1]:index_to_use[2]]
    }
  } else{
    output <- list("before" = buffer[index_to_use[[1]][1]:index_to_use[[1]][2]],
                   "after" = buffer[index_to_use[[2]][1]:index_to_use[[2]][2]])
  }

  return(output)
}
