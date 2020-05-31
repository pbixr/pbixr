#' @title Query 'DataModel' of a '.pbix'
#' @description A query of 'DataModel' of a '.pbix' currently open in
#' 'Power BI' is developed. The query is exchanged with 'Analysis Services'
#' via 'PowerShell'. Results are written to a temporary file, which is (1)
#' read into R and (2) deleted.
#' @author Don Diproto
#' @param sql_query SQL query.
#' @param connection_string Connection to 'DataModel' intiated in
#' 'Analysis Services'. Please note: (1) '.pbix' must be open in 'Power BI'
#' to connect to 'DataModel' and (2) the identifier and port used in the
#' connection change each time a '.pbix' is opened with 'Power BI'.
#' @return Result from a query of 'DataModel'.
#' @import dplyr
#' @export
#' @note 'Power BI' and 'PowerShell' are required.
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
#' OR_pathFileSample <- pathFileSample
#'
#' # Open the .pbix with 'Power BI' if it is not already open.
#' #
#' # Identify the right port
#' connections_open <- f_get_connections()
#' connections_open$pbix <- gsub(" - Power BI Desktop", "",
#' connections_open$pbix_name)
#' connections_open <- connections_open[which(connections_open$pbix ==
#' gsub("[.]pbix", "", basename(OR_pathFileSample))), ][1, ]
#' correct_port <- as.numeric(connections_open$ports)
#' # Construct the connection
#' connection_db <- paste0("Provider=MSOLAP.8;Data Source=localhost:",
#'                         correct_port, ";MDX Compatibility=1")
#' # Construct the Data Analysis Expressions query
#' sql_measures <- paste0("select MEASURE_NAME, EXPRESSION, MEASUREGROUP_NAME",
#'                       " from $SYSTEM.MDSCHEMA_MEASURES")
#' # Run the function
#' get_dax <- f_query_datamodel(sql_measures, connection_db)
#'   }
f_query_datamodel <- function(sql_query, connection_string) {
  # The query is exchanged with 'Analysis Services' via 'PowerShell' -----------
  temp_ps_file <- gsub("\\\\", "/", paste0(tempfile(), ".csv"))
  command <- paste0("function query_db {param([string] $connectionString, ",
  "[string] $sqlCommand);$connection = New-Object System.Data.OleDb.",
  "OleDbConnection $connectionString;$command = New-Object System.Data.OleDb."
  , "OleDbCommand $sqlCommand, $connection;$connection.Open();$adapter = ",
  "New-Object System.Data.OleDb.OleDbDataAdapter $command;$dataset = ",
  "New-Object System.Data.DataSet;[void] $adapter.Fill($dataSet);$connection.",
  "Close();$dataSet.Tables[0];};$output = query_db -sqlCommand '", sql_query,
  "' -connectionString '", connection_string, "' ; $output | Export-Csv -Path ",
  temp_ps_file, " -NoTypeInformation")
  system(paste0('powershell "', command, '"'))

  # Read and delete temporary file ---------------------------------------------
  read_output <- read.csv(temp_ps_file)
  file.remove(temp_ps_file)

  return(read_output)
}
