% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/f_compress_pbix.R
\name{f_compress_pbix}
\alias{f_compress_pbix}
\title{Convert a Collection of Files to a '.pbix'}
\usage{
f_compress_pbix(collection_files_pbix, output_pbix)
}
\arguments{
\item{collection_files_pbix}{Directory of the collection of files.}

\item{output_pbix}{Path of the modified '.pbix'.}
}
\value{
None
}
\description{
A collection of files from, or similar in structure to, a
decompressed '.pbix' is compressed, generating a '.pbix'.
}
\examples{
\dontrun{
# Get dummy data ------------------------------------------------------------
# Create a temporary directory
temp_dir <- file.path(tempdir(),"functionTest")
if(!dir.exists(temp_dir)) {
	dir.create(temp_dir)
}
sample_file_name <- "OR_sample_func.pbix"
pathFileSample <- file.path(temp_dir, sample_file_name)

# See if dummy data already exists in temporary directory
parent_temp_dir <- dirname(temp_dir)
existing_file <- list.files(parent_temp_dir,
pattern = sample_file_name, recursive = TRUE, full.names = TRUE)

# Download the sample .pbix if it doesn't exist
if (length(existing_file) == 0) {
   url_pt1 <- "https://github.com/KoenVerbeeck/PowerBI-Course/blob/"
   url_pt2 <- "master/pbix/TopMovies.pbix?raw=true"
   url <- paste0(url_pt1, url_pt2)
   req <- download.file(url, destfile = pathFileSample, mode = "wb")
} else {
   pathFileSample <- existing_file[1]
}
# Do stuff ------------------------------------------------------------------

pathFileSampleMod2 <- file.path(temp_dir, "sample_modified_f30.pbix")
dirFileSampleMod2 <- file.path(temp_dir, "sample_modified2_f30")
if(file.exists(pathFileSampleMod2) ) {
  file.remove(pathFileSampleMod2)
}
if(dir.exists(dirFileSampleMod2)) {
  unlink(dirFileSampleMod2, recursive = TRUE)
}
# Run the function
f_compress_pbix(dirFileSampleMod2, pathFileSampleMod2)
  }
}
\author{
Don Diproto
}
