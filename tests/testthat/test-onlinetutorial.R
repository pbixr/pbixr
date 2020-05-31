## Get dummy data -----------------------------------------------------------
## Create a temporary directory
#temp_dir <- file.path(tempdir(), "testTest")
#if (!dir.exists(temp_dir)) {
#  dir.create(temp_dir)
#}
#sample_file_name <- "OR_sample_test.pbix"
#path_file_sample <- file.path(temp_dir, sample_file_name)
#
## See if dummy data already exists in temporary directory
#parent_temp_dir <- dirname(temp_dir)
#existing_file <- list.files(parent_temp_dir,
#                            pattern = sample_file_name,
#                            recursive = TRUE, full.names = TRUE)
#
## Download the sample .pbix if it doesn't exist
#if (length(existing_file) == 0) {
#  url_pt1 <- "https://github.com/KoenVerbeeck/PowerBI-Course/blob/"
#  url_pt2 <- "master/pbix/TopMovies.pbix?raw=true"
#  url <- paste0(url_pt1, url_pt2)
#  req <- download.file(url, destfile = path_file_sample, mode = "wb")
#} else {
#  path_file_sample <- existing_file[1]
#}
#
## Tests --------------------------------------------------------------------
#test_that("f_clean_under_the_hood", {
#  path_file_sample_modified <- file.path(temp_dir, "sample_modified_t10.pbix")
#  dir_path_file_sample_modified <- file.path(temp_dir, "sample_modified_t10")
#  if (file.exists(path_file_sample_modified)) {
#    file.remove(path_file_sample_modified)
#  }
#  if (dir.exists(dir_path_file_sample_modified)) {
#    unlink(dir_path_file_sample_modified, recursive = TRUE)
#  }
#  f_clean_under_the_hood(
#    path_file_sample, dir_path_file_sample_modified,
#    path_file_sample_modified
#  )
#  expect_equal(file.exists(path_file_sample_modified), TRUE)
#})
#
#test_that("f_extract_images", {
#  image_reg <- "[.]png|[.]jpg"
#  test <- f_extract_images(path_file_sample, image_reg)
#  expect_equal(is.null(test[[2]]), FALSE)
#})
#
#test_that("f_get_dama", {
#  test <- f_get_dama(path_file_sample)
#  expect_equal(length(test), 45654)
#})
#
#test_that("f_get_dama_file", {
#  index_collection <- f_get_dama_index(path_file_sample)
#  # xml
#  test_xml <- f_get_dama_file(path_file_sample, "xml", index_collection)
#  # zip
#  test_zip <- f_get_dama_file(path_file_sample, "zip", index_collection)
#  # hf
#  test_hf <- f_get_dama_file(path_file_sample, "hf", index_collection)
#  expect_equal(length(test_xml), 43290)
#  expect_equal(length(test_zip), 45326)
#  expect_equal(length(test_hf), 2)
#})
#
#test_that("f_get_dama_index", {
#  test <- f_get_dama_index(path_file_sample)
#  expect_equal(length(test), 4)
#})
#
#test_that("f_get_dama_m_true", {
#  test <- f_get_dama_m(path_file_sample, TRUE)
#  expect_equal(length(test), 96)
#})
#
#test_that("f_get_dama_m_false", {
#  test <- f_get_dama_m(path_file_sample, FALSE)
#  expect_equal(length(test), 96)
#})
#
#test_that("f_get_dama_xml", {
#  test <- f_get_dama_xml_details(path_file_sample)
#  xml_start <- (test[[1]][1] / 2) + 1
#  xml_end <- test[[3]][1]
#  output <- f_get_dama_xml(path_file_sample, xml_start, xml_end)
#  expect_equal(class(output)[1], "xml_document")
#})
#
#test_that("f_get_dama_xml_data", {
#  test <- f_get_dama_xml_details(path_file_sample)
#  xml_start <- (test[[1]][1] / 2) + 1
#  xml_end <- test[[3]][1]
#  output <- f_get_dama_xml(path_file_sample, xml_start, xml_end)
#  get_xml_data <- f_get_dama_xml_data(output)
#  expect_equal(get_xml_data[[1]][1, 3], "sAAAAAA==")
#})
#
#test_that("f_get_dama_xml_details", {
#  test <- f_get_dama_xml_details(path_file_sample)
#  expect_equal(length(test), 3)
#})
#
#test_that("f_get_pbix_fir", {
#  variable <- paste0(
#    "Report/CustomVisuals/ImgViewerVisual1455487926945",
#    "/resources/ImgViewerVisual.css"
#  )
#  test <- f_get_pbix_fir(path_file_sample, variable)
#  expect_equal(length(test), 679)
#})
#
#test_that("f_get_pbix_info", {
#  test <- f_get_pbix_info(path_file_sample)
#  expect_equal(nrow(test), 18)
#})
#
#test_that("f_read_any_json", {
#  gsub__1 <- paste0(".*sections")
#  # Note the difference with the help file
#  # gsub__2 <- "\{\"id\":0,\"sections"
#  gsub__2 <- "{\"id\":0,\"sections"
#  test <- f_read_any_json(
#    path_file_sample, "Report/Layout",
#    gsub__1, gsub__2
#  )
#  expect_equal(test[[2]]$name[1], "ReportSection")
#})
#
#test_that("f_read_layout", {
#  gsub__1 <- paste0(".*sections")
#  # Note the difference with the help file
#  # gsub__2 <- "\{\"id\":0,\"sections"
#  gsub__2 <- "{\"id\":0,\"sections"
#  test <- f_read_layout(path_file_sample, gsub__1, gsub__2)
#  expect_equal(test[[2]]$name[1], "ReportSection")
#})
#
#test_that("f_remove_file", {
#  path_file_sample_modified <- file.path(temp_dir, "sample_modified_t20.pbix")
#  dir_path_file_sample_modified <- file.path(temp_dir, "sample_modified_t20")
#  if (file.exists(path_file_sample_modified)) {
#    file.remove(path_file_sample_modified)
#  }
#  if (dir.exists(dir_path_file_sample_modified)) {
#    unlink(dir_path_file_sample_modified, recursive = TRUE)
#  }
#  f_remove_file(
#    path_file_sample, dir_path_file_sample_modified, path_file_sample_modified,
#    "DataModel"
#  )
#  expect_equal(file.exists(path_file_sample_modified), TRUE)
#})
#
#test_that("f_decompress_pbix", {
#  output_pbix_file <- gsub(
#    "OR_sample_test.pbix", "OR_unzip_pbix",
#    path_file_sample
#  )
#  f_decompress_pbix(path_file_sample, output_pbix_file)
#  expect_equal(length(list.files(output_pbix_file)), 9)
#})
#
#test_that("f_compress_pbix", {
#  path_file_sample_modified <- file.path(temp_dir, "sample_modified_t30.pbix")
#  output_pbix_file <- gsub("sample.pbix", "unzip_pbix", path_file_sample)
#  if (file.exists(path_file_sample_modified)) {
#    file.remove(path_file_sample_modified)
#  }
#  f_compress_pbix(output_pbix_file, path_file_sample_modified)
#  expect_equal(file.exists(path_file_sample_modified), TRUE)
#})
#
#test_that("f_get_connections", {
#  connections_open <- f_get_connections() %>%
#    mutate(pbix = gsub(" - Power BI Desktop", "", pbix_name)) %>%
#    filter(pbix == gsub("[.]pbix", "", basename(path_file_sample)))
#  correct_port <- as.numeric(connections_open$ports)
#  connection_db <- paste0(
#    "Provider=MSOLAP.8;Data Source=localhost:",
#    correct_port, ";MDX Compatibility=1"
#  )
#  # Expression to get the DAX queries
#  sql_measures <- paste0(
#    "select MEASURE_NAME, EXPRESSION, MEASUREGROUP_NAME",
#    " from $SYSTEM.MDSCHEMA_MEASURES"
#  )
#  # Query the analysis service
#  get_dax <- f_query_datamodel(sql_measures, connection_db)
#  # Display a result
#  t_data <- t(tail(get_dax, 1))
#  colnames(t_data) <- NULL
#
#  expect_equal(t_data[1], "imdbVotes running total in Title")
#})
#
#test_that("f_search_xml", {
#  # Get the start and end positions
#  in1 <- f_get_dama_xml_details(path_file_sample)
#  xml_start <- (in1[[1]][1] / 2) + 1
#  xml_end <- in1[[3]][1]
#  # Get the .xml Within DataMashup
#  output <- f_get_dama_xml(path_file_sample, xml_start, xml_end)
#  # Pattern for query names
#  get_line <- "//ItemLocation[ItemType = \"Formula\"]//ItemPath"
#  # Run the function
#  test <- f_search_xml(output, get_line, 1)
#  expect_equal(test[65], "Section1/TopMovies/Expanded%20NewColumn")
#})
