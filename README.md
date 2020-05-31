# pbixr

The 'pbixr' package enables one to access data and metadata from ['Microsoft' 'Power BI'](https://web.archive.org/web/20191225013754/https://powerbi.microsoft.com/en-us/why-power-bi/) documents: 'Power Query M' formulas and 'Data Analysis Expressions' ('DAX') queries and their properties, report layout and style, and data and data models.

'Microsoft' 'Power BI' is a big deal -- more than 200,000 organisations in 205 countries were reported as using it in [February 16, 2017](https://web.archive.org/web/20170906094058/https://powerbi.microsoft.com/en-us/blog/gartner-positions-microsoft-as-a-leader-in-bi-and-analytics-platforms-for-ten-consecutive-years/).

With extensive use of 'Power BI' and production of '.pbix' files, managing and analysing '.pbix' files can be challenging for individuals and organisations.

The `pbixr` package in R has several functions that can help.

## Installation

```r
# Install devtools from CRAN
install.packages("pbixr")

# Or the development version from GitHub:
# install.packages("pbixr")
devtools::install_github("pbixr/pbixr")
```

## Usage

Please refer to the [vignette](https://cran.r-project.org/web/packages/pbixr/vignettes/explore.html).