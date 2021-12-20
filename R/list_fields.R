#' List Fields of a Knack Object
#'
#' @param object A string containing the knack object to retrieve fields from. Ex: 'object_23'
#' @param details A logical value saying whether to include all details.
#'
#' @return A data frame containing descriptions of fields in a Knack object
#' @export
#'
#' @examples
#' \dontrun{
#' # List fields of a single object
#' list_fields("object_23")
#'
#' # List fields of every object
#' objects <- list_objects()
#' sapply(objects$key, list_fields)
#' }
#'
list_fields <- function(object, details = FALSE) {
  # Check to see if Knack API credentials are set
  if (is.null(getOption("api_id")) |
      is.null(getOption("api_key"))) {
    return (print("Please set API credentials using set_credentials."))
  }

  # Set API base url
  api_url <-
    paste0("https://api.knack.com/v1/objects/", object, "/fields")

  # Retrieve Objects
  response <-
    GET(
      api_url,
      add_headers(
        "X-Knack-Application-Id" = getOption("api_id"),
        "X-Knack-REST-API-Key" = getOption("api_key")
      )
    )
  data <-
    (fromJSON(content(
      response, type = "text", encoding = "UTF-8"
    )))

  # Return details if desired
  if (details) {
    return (data)
  } else {
    return(data$fields[c(1, 2, 4)])
  }

}
