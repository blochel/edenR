# Functions to find and download EDEN water depth data
#' @name get_metadata
#'
#' @title Get EDEN metadata
#'
#' @export
#'
get_metadata <- function() {
  url <- "https://sflthredds.er.usgs.gov/thredds/catalog/eden/depths/catalog.html"
  metadata <- url |>
    rvest::read_html() |>
    rvest::html_table()
  metadata <- as.data.frame(metadata[[1]]) |>
    dplyr::filter(Dataset != "depths") |> # Drop directory name from first row
    dplyr::rename(
      dataset = Dataset, size = Size,
      last_modified = `Last Modified`
    ) |>
    dplyr::mutate(
      last_modified = as.POSIXct(last_modified,
                                 format = "%Y-%m-%dT%H:%M:%S"
      ),
      year = as.integer(substr(dataset, start = 1, stop = 4))
    )
}

#' @name get_data_urls
#'
#' @title Get EDEN depths data URLs for download
#'
#' @param file_names file names to download from metadata
#'
#' @return list of file urls
#'
#' @export
#'
get_data_urls <- function(file_names) {
  base_url <- "https://sflthredds.er.usgs.gov/thredds/fileServer/eden/depths"
  urls <- file.path(base_url, file_names)
  return(list(file_names = file_names, urls = urls))
}

#' @name get_last_download
#'
#' @title Get list of EDEN depths data already downloaded
#'
#' @param eden_path path where the EDEN data should be stored
#' @param metadata EDEN file metadata
#' @param force_update if TRUE update all data files even if checks indicate
#'   that remote files are unchanged since the current local copies were
#'   created
#'
#' @return table of files already downloaded
#'
#' @export
#'
get_last_download <- function(eden_path = file.path("~/water"),
                              metadata = get_metadata(),
                              force_update = FALSE) {
  if ("last_download.csv" %in% list.files(eden_path) & !force_update) {
  }