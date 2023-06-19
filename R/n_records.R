#' Determine the Number of Records in an Object
#'
#' @param table_name A string containing the table name.
#'
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#'
#' @return An integer representing the number of records in the object.
#' @export
#'
n_records <- function(table_name) {
  # Check to see if Knack API credentials are set
  if (is.null(getOption("api_id")) |
      is.null(getOption("api_key"))) {
    stop("Please set API credentials using set_credentials.")
  }

  # Get Table Key
  all_objects <- list_objects()
  table_key <- all_objects$key[which(all_objects$name == table_name)]
  if (identical(character(0), table_key)){
    stop(
      paste(
        "The table with name:",
        table_name,
        "was not found"
      )
    )
  }

  # Set base url
  api_url <-
    paste0("https://api.knack.com/v1/objects/",
           table_key,
           "/records?rows_per_page=1")

  # Make the GET request
  result <- GET(
    api_url,
    add_headers(
      "X-Knack-Application-Id" = getOption("api_id"),
      "X-Knack-REST-API-Key" = getOption("api_key")
    )
  )

  # Return only the number of records
  fromJSON(content(result, as = "text"))$total_records


}
