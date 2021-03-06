% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{rexcel_read_workbook}
\alias{rexcel_read_workbook}
\title{Read an Excel workbook}
\usage{
rexcel_read_workbook(path, sheets = NULL, progress = TRUE)
}
\arguments{
\item{path}{Path to the xlsx file to load.  xls files are not supported.}

\item{sheets}{Character or integer vector of sheets to read, or
\code{NULL} to read all sheets (the default)}

\item{progress}{Display a progress bar?}
}
\description{
Read an entire workbook
}

