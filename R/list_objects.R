#' List Knack Objects
#'
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#'
#' @return A data frame listing the Knack Objects (i.e. Tables) available in the Knack Database
#' @export
#'
#' @examples
#' tail(list_objects())
list_objects <- function(){

  # Check to see if Knack API credentials are set
  if (is.null(getOption("api_id")) |
      is.null(getOption("api_key"))) {
    return (print("Please set API credentials using set_credentials."))
  }

  # Retrieve Objects
  response <- GET("https://api.knack.com/v1/objects/",
                  add_headers(
                    "X-Knack-Application-Id" = getOption("api_id"),
                    "X-Knack-REST-API-Key" = getOption("api_key")
                  )
  )
  fromJSON(content(response, type = "text"))
}
