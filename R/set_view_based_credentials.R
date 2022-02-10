#' Set View-Based Knack Credentials
#'
#' @param email A string containing the login email address.
#' @param password A string containing the login password.
#' @param api_id A string containing the Knack API ID.
#' 
#' @importFrom jsonlite toJSON
#' @importFrom jsonlite fromJSON
#' @importFrom httr content
#' @importFrom httr POST
#' @importFrom httr add_headers
#' @importFrom httr http_error
#' @importFrom httr http_status
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' set_view_based_credentials('example@@example.com',
#'                            'verysecretpassword',
#'                            '60a2a941bc3064001b208e21')
#' 
#' }
set_view_based_credentials <- function(email, password, api_id) {
  
  # Set the base url
  url <-
    paste0("https://api.knack.com/v1/applications/",
           api_id,
           "/session")
  
  # Convert data to JSON package
  data <- list(email = email,
               password = password)
  package <- toJSON(data, auto_unbox = TRUE)
  
  # Send the post request
  response <- POST(url,
                   add_headers("Content-Type" = "application/json"),
                   body = package)
  
  # Check if the login was successful
  if (http_error(response)){
    return("The API call failed. Please double check your credentials")
  }
 
  # Retrieve the login token
  user_token <- fromJSON(content(response, type = "text", encoding = "UTF-8"))$session$user$token
  
  # Set user token and api_id to global options
  options(api_id = api_id)
  options(user_token = user_token)
  
  # Return a success message
  http_status(response)$message
}