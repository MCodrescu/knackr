#' List Fields and Data Types of a Knack Object
#'
#' @param table_name The name of the table to query.
#'
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#'
#' @return A data frame containing descriptions of fields.
#' @export
#'
list_fields <- function(
    table_name
){
  # Check to see if Knack API credentials are set
  if (is.null(getOption("api_id")) |
      is.null(getOption("api_key"))) {
    stop("Please set API credentials using set_credentials.")
  }

  all_objects <- list_objects()
  table_key <- all_objects$key[which(all_objects$name == table_name)]

  api_url <- paste0(
    "https://api.knack.com/v1/objects/",
    table_key,
    "/fields"
  )

  # Retrieve Objects
  response <- httr::GET(
    api_url,
    httr::add_headers(
      "X-Knack-Application-Id" = getOption("api_id"),
      "X-Knack-REST-API-Key" = getOption("api_key")
    )
  )

  jsonlite::fromJSON(httr::content(response, type = "text", encoding = "UTF-8"))$fields
}
