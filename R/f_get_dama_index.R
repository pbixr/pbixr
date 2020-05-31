#' @title Get Byte Index of Files within 'DataMashup'
#' @description The position of the start and end bytes of different files, or
#' their components, within 'DataMashup' are identified.
#' @author Don Diproto
#' @param input_file_pbix Path of the input '.pbix'.
#' @return Bytes of 'DataMashup', including [[1]] start and end of a
#' parsable '.zip' file, [[2]] start of each '.zip' signature, [[3]] start and
#' end of xml, and [[4]] total length of 'DataMashup'.
#' @import dplyr
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
#' # Run the function
#' test <- f_get_dama_index(pathFileSample)
#'   }
f_get_dama_index <- function(input_file_pbix) {
  # Extract DataMashup ---------------------------------------------------------
  buffer <- f_get_dama(input_file_pbix)

  # Write DataMashup to temporary file -----------------------------------------
  temp_file <- tempfile()
  zz <- file(temp_file, "wb")
  writeBin(buffer, zz)
  close(zz)
  pbix_size <- file.info(temp_file)$size

  # Identify markers in zip ----------------------------------------------------
  # The magic number for zip starts with 504b. These numbers include:
  # 04034b50, 08074b50, 02014b50 06054b50. Written in reverse: 504b0102,
  # 504b0304, 504b0506, 504b0708
  zip_signature_char <- c("504b0102", "504b0304", "504b0506", "504b0708")
  zip_indicator_50 <- c()
  check_50 <- as.raw(0x50)
  zip_indicator_index <- 1

  # Identify the uncompressed XML
  # The magic number for XML is 3c3f786d6c20
  xml_indicator_3c <- c()
  check_3c <- as.raw(0x3c)
  check_3f <- as.raw(0x3f)
  check_78 <- as.raw(0x78)
  check_6d <- as.raw(0x6d)
  check_6c <- as.raw(0x6c)
  check_20 <- as.raw(0x20)
  xml_indicator_index <- 1
  xml_indicator_all_char <- "3c3f786d6c20"

  # Stream the binary file and perform checks for zip and xml
  zip_full <- c()
  zz <- file(temp_file, "rb")
  temp_file_length <- file.info(temp_file)$size
  for (ri in seq_along(1:temp_file_length)) {
    o1 <- readBin(zz, "raw", 1)
    zip_full[ri] <- o1
    if (o1 == check_50) {
      zip_indicator_50[zip_indicator_index] <- ri
      zip_indicator_index <- zip_indicator_index + 1
    }
    if (o1 == check_3c) {
      xml_indicator_3c[xml_indicator_index] <- ri
      xml_indicator_index <- xml_indicator_index + 1
    }
  }
  close(zz)
  rm(temp_file)

  # Locate zip in DataMashup ---------------------------------------------------
  check_sequence_full_variable <- list()
  for (csfv_i in seq_along(zip_indicator_50)) {
    o1 <- zip_indicator_50[csfv_i]
    o2 <- o1:(o1 + 3)
    if (length(which(o2 > length(zip_full))) == 0) {
      check_sequence_full_variable[[csfv_i]] <- data.frame(
        val = paste0(zip_full[o2], collapse = ""), id = csfv_i,
        stringsAsFactors = FALSE)
    } else {
      check_sequence_full_variable[[csfv_i]] <- data.frame(val = NA,
        id = csfv_i, stringsAsFactors = FALSE)
    }
  }
  check_sequence_full_df <- stats::na.omit(dplyr::bind_rows(
    check_sequence_full_variable))
  zip_signature_char_df <- data.frame(val = zip_signature_char, result = TRUE,
                                      stringsAsFactors = FALSE)
  check_merge_zip_signature <- merge(zip_signature_char_df,
                                     check_sequence_full_df, by.x = "val",
                                     by.y = "val")
  check_zip_result <- check_merge_zip_signature[order(
    check_merge_zip_signature$id), c(1, 3)]
  index_datamashup <- c(zip_indicator_50[head(check_zip_result$id, 1)],
                        (zip_indicator_50[tail(check_zip_result$id, 1)] - 1))

  zip_header_start <- cbind(check_zip_result, zip_indicator_50[
    check_zip_result$id])
  zip_header_start <- zip_header_start[, c(1, 3)]
  colnames(zip_header_start) <- c("signature", "position")

  # Locate XML in DataMashup ---------------------------------------------------
  #
  first_3f <- which(zip_full[xml_indicator_3c + 1] == check_3f)
  second_78 <- which(zip_full[xml_indicator_3c + 2] == check_78)
  third_6d <- which(zip_full[xml_indicator_3c + 3] == check_6d)
  fourth_6c <- which(zip_full[xml_indicator_3c + 4] == check_6c)
  fifth_20 <- which(zip_full[xml_indicator_3c + 5] == check_20)

  char_matches <- c(which(first_3f %in% second_78),
                    which(first_3f %in% third_6d),
                    which(first_3f %in% fourth_6c),
                    which(first_3f %in% fifth_20))
  char_match_count <- table(char_matches)
  char_match_ind <- sort(unique(as.numeric(names(char_match_count[which(
    char_match_count == max(char_match_count))]
  ))))
  # which indicators match
  first_3f <- first_3f[char_match_ind]
  xml_start_test <- FALSE
  xml3fi <- 1
  loop_end <- length(first_3f) + 1
  while (xml_start_test == FALSE & xml3fi < loop_end) {
    potential_xml_index <- xml_indicator_3c[first_3f[xml3fi]]
    potential_xml_index <- potential_xml_index:(potential_xml_index + 5)
    potential_xml_start <- zip_full[potential_xml_index]
    potential_xml_start_chr <- paste0(potential_xml_start, collapse = "")
    xml_start_test <- potential_xml_start_chr == xml_indicator_all_char
    xml3fi <- xml3fi + 1
  }

  xml_start <- first_3f[1]
  start_xml_index <-  xml_indicator_3c[xml_start]
  # Assume that xml ends at the next PK
  start_differences <- zip_indicator_50[check_zip_result$id] - start_xml_index
  xml_end <- zip_indicator_50[check_zip_result[which(start_differences > 0),
                                               "id"]]
  # Extract XML from DataMashup
  xml_sequence <- start_xml_index:xml_end
  xml_only <- zip_full[xml_sequence]
  # Remove everything after last ">"
  xml_bracket_last <- tail(which(xml_only == 0x3E), 1)
  xml_end <- xml_sequence[xml_bracket_last]
  xml_start_end <- c(start_xml_index, xml_end)

  # Return positions -----------------------------------------------------------
  output <- list("zip_start_end" = index_datamashup,
                 "zip_header_start" = zip_header_start,
                 "xml_start_end" = xml_start_end,
                 "datamashup_end" = pbix_size)
  return(output)
}
