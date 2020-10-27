#' @title Query 'DataModel' of a '.pbix'
#' @description A query of 'DataModel' of a '.pbix' currently open in
#' 'Power BI' is developed. The query is exchanged with 'Analysis Services'
#' via 'PowerShell'. Results are written to a temporary file, which is (1)
#' read into R and (2) deleted.
#' @author Don Diproto
#' @param queryPowerBI Query of 'DataModel' (e.g. 'DAX', 'MDX').
#' @param connection_string Connection to 'DataModel' intiated in
#' 'Analysis Services'. Please note: (1) '.pbix' must be open in 'Power BI'
#' to connect to 'DataModel' and (2) the identifier and port used in the
#' connection change each time a '.pbix' is opened with 'Power BI'.
#' @return Result from a query of 'DataModel'. For one table, a data.frame
#' is returned. For many tables, a list is returned. For an error, perhaps
#' due to incorrect 'DAX' or 'MDX' or incorrect connection, a list of 1
#' equal to NULL.
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
#'
#' # Example 1
#' # No need to change the syntax
#' queryPowerBI <- "evaluate TopMovies"
#' getQueryPowerBIData <- f_query_datamodel(queryPowerBI, connection_db)
#' str(getQueryPowerBIData)
#'
#' # Example 2
#' # Escape dollar sign so that it can run via PowerShell
#' queryPowerBI <- paste0("select MEASURE_NAME, EXPRESSION, MEASUREGROUP_NAME ",
#'                     "from `$SYSTEM.MDSCHEMA_MEASURES")
#' getQueryPowerBIData <- f_query_datamodel(queryPowerBI, connection_db)
#' str(getQueryPowerBIData)
#'
#' # Example 3
#' # Escape double quotes so that it can run via PowerShell
#' queryPowerBI <- paste0("evaluate(summarizecolumns('TopMovies'[Rank],",
#'                     "'TopMovies'[Title],\\\\\\"\\\\\\"Value\\\\\\"\\\\\\",",
#'                     "TopMovies[Avg Metascore]))")
#' getQueryPowerBIData <- f_query_datamodel(queryPowerBI, connection_db)
#' str(getQueryPowerBIData)
#'
#' # Example 4
#' # Return results from multiple EVALUATE.
#' # Remember to put white spaces after statements like DEFINE and EVALUATE
#' # the code runs
#' queryPowerBI <- paste0(
#'   "DEFINE ",
#'   "VAR test_average = CALCULATE(AVERAGE('TopMovies'[imdbRating])) ",
#'   "VAR test_median = CALCULATE(MEDIAN('TopMovies'[imdbRating])) ",
#'   "EVALUATE ",
#'   "  ROW( ",
#'   "    \\\\\\"\\\\\\"MinRuntime\\\\\\"\\\\\\", CALCULATE(MIN('TopMovies'[Runtime])),",
#'   "    \\\\\\"\\\\\\"MaxRuntime\\\\\\"\\\\\\", CALCULATE(MAX('TopMovies'[Runtime])),",
#'   "    \\\\\\"\\\\\\"average\\\\\\"\\\\\\", test_average) ",
#'   "EVALUATE ",
#'   "  ROW(",
#'   "    \\\\\\"\\\\\\"MinRuntime\\\\\\"\\\\\\", CALCULATE(MIN('TopMovies'[Runtime])),",
#'   "    \\\\\\"\\\\\\"MaxRuntime\\\\\\"\\\\\\", CALCULATE(MAX('TopMovies'[Runtime])),",
#'   "    \\\\\\"\\\\\\"median\\\\\\"\\\\\\", test_median)"
#' )
#' getQueryPowerBIData <- f_query_datamodel(queryPowerBI, connection_db)
#' str(getQueryPowerBIData[[1]])
#' str(getQueryPowerBIData[[2]])
#'
#' # Example 5
#' # Use single quotes when white space occurs in table name
#' # Note that single quotation marks don't have to be escaped for
#' # 'PowerShell'.
#' queryPowerBI <- "evaluate 'Genre Bridge'"
#' getQueryPowerBIData <- f_query_datamodel(queryPowerBI, connection_db)
#' str(getQueryPowerBIData)
#'
#' # Example 6
#' # Statement that won't work.
#' queryPowerBI <- "hello, world"
#' getQueryPowerBIData <- f_query_datamodel(queryPowerBI, connection_db)
#' getQueryPowerBIData
#'   }
f_query_datamodel <- function(queryPowerBI, connection_string) {
  statusOptionFancyQuotes <- getOption("useFancyQuotes")

  if (statusOptionFancyQuotes == FALSE) {
    options(useFancyQuotes = TRUE)
  }

  sqlQuery <- dQuote(queryPowerBI)

  command <- paste0(
    "try {",
    "function query_db {param([string] $connectionString, [string] $sqlCommand);",
    "$connection = New-Object System.Data.OleDb.OleDbConnection $connectionString;",
    "$command = New-Object System.Data.OleDb.OleDbCommand $sqlCommand, $connection;",
    "$connection.Open();",
    "$adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command;",
    "$dataset = New-Object System.Data.DataSet;",
    "[void] $adapter.Fill($dataSet);",
    "$connection.Close();",
    "$queryTables = $dataSet.Tables;",
    "$tableCount = $queryTables.Count;",
    "$dirTempFile = @();",
    "foreach ($table in $queryTables) {",
    "    $filename = [System.IO.Path]::GetTempFileName(); ",
    "    $dirTempFile += $filename; ",
    "    $table | Export-Csv -Path $filename -NoTypeInformation;",
    "    };",
    "$outarray = @();",
    "foreach ($item in $dirTempFile)",
    "    {",
    "        $outarray += New-Object PsObject -property @{",
    "        'file' = [string]$item",
    "        }",
    "    }; ",
    "$dirTempParent = [System.IO.Path]::GetTempFileName(); ",
    "$outarray | Export-Csv -Path $dirTempParent -NoTypeInformation;",
    "Write-Host $dirTempParent;",
    "};",
    "$output = query_db -sqlCommand ",
    sqlQuery," -connectionString '",
    connection_string, "';",
    "}",
    "catch {Write-Host 'ERROR'};"
  )
  pathOfTempFile <- system(paste0('powershell "', command, '"'), intern = TRUE)

  if (statusOptionFancyQuotes == FALSE) {
    options(useFancyQuotes = FALSE)
  }

  pathFileTest <- pathOfTempFile == "ERROR"
  if (!pathFileTest == TRUE) {
    getTempFileLocations <- read.csv(pathOfTempFile, stringsAsFactors = FALSE)
    getTempFileData <- vector("list", length = nrow(getTempFileLocations))
    nTablesReturned <- nrow(getTempFileLocations)
    for (getTempFileData_i in seq_along(1:nTablesReturned)) {
      identifyInputTempFile_i <- getTempFileLocations[[getTempFileData_i, 1]]
      getInputTempFile_i <- read.csv(identifyInputTempFile_i,
                                     stringsAsFactors = FALSE)
      getTempFileData[[getTempFileData_i]] <- getInputTempFile_i
      file.remove(identifyInputTempFile_i)
    }
    file.remove(pathOfTempFile)

    nReturnOneTableOnly <- 1
    if (nTablesReturned == nReturnOneTableOnly) {
      getTempFileData <- getTempFileData[[nReturnOneTableOnly]]
    }
    return(getTempFileData)
  } else {
    return(list(NULL))
  }
}
