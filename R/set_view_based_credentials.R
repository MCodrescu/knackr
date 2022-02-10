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
  
  # Retrieve the login token
  user_token <- fromJSON(content(response, type = "text"))$session$user$token
  
  # Set user token and api_id to global options
  options(api_id = api_id)
  options(user_token = user_token)
}