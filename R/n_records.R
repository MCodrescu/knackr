#' Determine the Number of Records in an Object
#'
#' @param object A string containing the object number. Ex: 'object_2'
#'
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#'
#' @return An integer representing the number of records in the object.
#' @export
#'
#' @examples
#' \dontrun{
#' n_records('object_2')
#' }
n_records <- function(object) {
  # Check to see if Knack API credentials are set
  if (is.null(getOption("api_id")) |
      is.null(getOption("api_key"))) {
    return (print("Please set API credentials using set_credentials."))
  }

  # Set base url
  api_url <-
    paste0("https://api.knack.com/v1/objects/",
           object,
           "/records?rows_per_page=0")

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
