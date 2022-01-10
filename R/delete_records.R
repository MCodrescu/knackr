#' Delete Records
#'
#' @param object A character string of the knack object. Ex: 'object_23'
#' @param record_id A character string of unique digits identifying the record. Ex: '61dc8e97403aa7116229c90a'
#'
#' @importFrom httr DELETE
#' @importFrom httr add_headers
#' @importFrom httr http_error
#' @importFrom httr http_status
#'
#' @return A http status message
#' @export
#'
#' @examples
#' \dontrun{
#' delete_records("object_23",
#'                "61dc8e97403aa7116229c90a")
#' }
delete_records <- function(object, record_id) {
  # Check to see if Knack API credentials are set
  if (is.null(getOption("api_id")) |
      is.null(getOption("api_key"))) {
    return (print("Please set API credentials using set_credentials."))
  }

  # Create the base url
  api_url <-
    paste0("https://api.knack.com/v1/objects/",object,
           "/records/",
           record_id)

  # Send the http delete request
  result <- DELETE(
    api_url,
    add_headers(
      "X-Knack-Application-Id" = getOption("api_id"),
      "X-Knack-REST-API-Key" = getOption("api_key")
    )
  )


  #If error then stop and return error
  if (http_error(result)) {
    return (http_status(result)$message)
  }


  # Return the result
  http_status(result)$message


}
