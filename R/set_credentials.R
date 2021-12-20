
#' Set API Authentication Credentials
#'
#' @param api_id A string containing the Knack API ID
#' @param api_key A string containing the Knack API Key
#'
#' @return No value is returned. API ID and API Key are set in the R session.
#' @export
#'
set_credentials <- function(api_id, api_key){

  options(api_id = api_id)
  options(api_key = api_key)

}
