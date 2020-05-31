#' @title Get 'Analysis Services' Connections to an Open '.pbix'
#' @description A query to link an open '.pbix'(s) with relevant
#' 'Analysis Services' connection
#' information is developed. The query is executed via 'PowerShell'.
#' @author Don Diproto
#' @return The '.pbix' and associated port.
#' @export
#' @note An input is not required for this function. 'Power BI' and
#' 'PowerShell' are required.
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
#' #
#' # Open the .pbix with 'Power BI' if it is not already open.
#' #
#' # Run the function
#' connections_open <- f_get_connections()
#'   }
f_get_connections <- function() {
  # The query is executed via 'PowerShell' -------------------------------------
  command <- paste0("$pbi_1 = get-Process PBIDesktop | select ID, ",
  "mainwindowtitle;$count_raw =  get-Process PBIDesktop;$loopEnd = $count_raw.",
  "Count;if($loopEnd -gt 1) {;For ($i=0;  $i -lt $loopEnd;  $i++)  {;    ",
  "$pbi_2= $pbi_1[($i)];    $processes = Get-WmiObject Win32_Process ;    ",
  "$processByParent =  $processes | Group-Object -AsHashTable ParentProcessId;",
  "$process_children = Foreach ($Key in ($processByParent.GetEnumerator() | ",
  "Where-Object {$_.Name -eq $pbi_2.Id.ToString()})) {$Key.Value};    ",
  "$as_location_raw = $process_children | Where-Object {$_.ProcessName -eq ",
  "'msmdsrv.exe'} | select CommandLine;    $as_location_clean = ",
  "$as_location_raw -replace '.* -s ', '';    ",
  "$output = $pbi_2.MainWindowTitle.",
  "ToString() + '|' + $as_location_clean.ToString();    Write-Host $output;};}",
  ";if($loopEnd -eq 1) {;    $pbi_2 = $pbi_1[0];    ",
  "$processes = Get-WmiObject ",
  "Win32_Process ;    $processByParent =  $processes | Group-Object ",
  "-AsHashTable ParentProcessId ;    $process_children = Foreach ($Key in ",
  "($processByParent.GetEnumerator() | Where-Object {$_.Name -eq $pbi_2.Id.",
  "ToString()})) {$Key.Value};    $as_location_raw = $process_children | ",
  "Where-Object {$_.ProcessName -eq 'msmdsrv.exe'} | select CommandLine;    ",
  "$as_location_clean = $as_location_raw -replace '.* -s ', '';    $output = ",
  "$pbi_2.MainWindowTitle.ToString() + '|' + $as_location_clean.ToString();   ",
  "Write-Host $output;} ;;")
  output <- system(paste0('powershell "', command, '"'), intern = TRUE)

  # Interpret the results of the 'PowerShell' query ----------------------------
  if (length(output) > 0) {
    if (output[1] != "Cannot index into a null array.") {
      # There is some relevant data
      clean_data <- as.data.frame(matrix(unlist(lapply(output, function
         (z)strsplit(z, "[|]"))), ncol = 2, byrow = TRUE),
         stringsAsFactors = FALSE)
      colnames(clean_data) <- c("pbix_name", "port")
      clean_data$port <- gsub("\"", "", gsub("\\}", "", clean_data$port))

      # Identify the port file
      ports <- unlist(lapply(clean_data$port, function(z) {
        o1 <- list.files(z, pattern = ".*msmdsrv.port.txt", full.names = TRUE)
        if (file.exists(o1)) {
          o2 <- as.character(scan(o1, skipNul = TRUE))
        } else {
          o2 <- NA
        }
        return(o2)
      }))
      clean_data$ports <- ports
      clean_data <- clean_data[, c(1, 3)]
    }
    if (output[1] == "Cannot index into a null array.") {
      # The function probably executed before the .pbix was fully open
      clean_data <- data.frame("pbix_name" = NA, "port" = NA)
    }
  } else {
    # The function probably executed when a .pbix was not open
    clean_data <- data.frame("pbix_name" = NA, "port" = NA)
  }

  return(clean_data)
}
