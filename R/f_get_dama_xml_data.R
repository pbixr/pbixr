#' @title Get Data from an '.xml' within 'DataMashup'
#' @description The '.xml' extracted from 'DataMashup' is queried.
#' @author Don Diproto
#' @param input_file_xml The '.xml' within 'DataMashup'.
#' @return Data from the '.xml' within 'DataMashup'.
#' @import dplyr xml2
#' @export
#' @seealso Uses: \code{\link{f_search_xml}}.
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
#' # Get the .xml Within DataMashup
#' output <- f_get_dama_xml(pathFileSample, xml_start, xml_end)
#' # Run the function
#' get_xml_data <- f_get_dama_xml_data(output)
#'   }
f_get_dama_xml_data <- function(input_file_xml) {
  # Get query variables --------------------------------------------------------
  # Get the names of the queries
  get_line <- "//ItemLocation[ItemType = \"Formula\"]//ItemPath"
  query_names <- grep(".*/.*/", f_search_xml(input_file_xml, get_line, 1),
                      invert = TRUE, value = TRUE)

  # Get properties of all queries ----------------------------------------------
  query_base_all <- "//Item[ItemLocation//ItemType = \""
  query_entry_value_all <-
    paste0(query_base_all, "AllFormulas", "\"]//StableEntries//Entry//@Value")
  query_entry_type_all <-
    paste0(query_base_all, "AllFormulas", "\"]//StableEntries//Entry//@Type")

  query_value_all <- input_file_xml %>%
    xml2::xml_find_all(query_entry_value_all) %>%
    xml2::xml_text()
  query_type_all <- input_file_xml %>%
    xml2::xml_find_all(query_entry_type_all) %>%
    xml2::xml_text()
  query_df_all <- data.frame(query = "AllFormulas", type = query_type_all,
                             value = query_value_all, stringsAsFactors = FALSE)

  # Get properties of each query -----------------------------------------------
  query_base <- "//Item[ItemLocation//ItemPath = \""
  query_values_list <- lapply(query_names, function(query_name_i) {
    query_entry_value <-
      paste0(query_base, query_name_i, "\"]//StableEntries//Entry//@Value")
    query_entry_type <-
      paste0(query_base, query_name_i, "\"]//StableEntries//Entry//@Type")

    query_value <- input_file_xml %>%
      xml2::xml_find_all(query_entry_value) %>%
      xml2::xml_text()
    query_type <- input_file_xml %>%
      xml2::xml_find_all(query_entry_type) %>%
      xml2::xml_text()
    query_df_each <- data.frame(query = query_name_i, type = query_type,
                                value = query_value, stringsAsFactors = FALSE)
    return(query_df_each)
  })
  query_values_df <- (dplyr::bind_rows(query_values_list))

  # Get query steps ------------------------------------------------------------
  query_steps <- input_file_xml %>%
  xml2::xml_find_all("//ItemPath") %>%
    xml2::xml_text()

  # Return all results ---------------------------------------------------------
  output <-
    list(all = query_df_all, each = query_values_df, steps = query_steps)
  return(output)
}
