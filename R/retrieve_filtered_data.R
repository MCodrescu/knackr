library(jsonlite)
library(httr)



retrieve_filtered_data <-
  function(object,
           api_id,
           api_key,
           include_raw = FALSE,
           filter_field = NULL,
           match = c("and", "or"),
           operator = c(
             "contains",
             "does not contain",
             "is",
             "is not",
             "starts with",
             "ends with",
             "is blank",
             "is not blank",
             "is after",
             "is before",
             "is today"
           ),
           value = NULL) {
    # Set base url
    api_url <-
      paste0("https://api.knack.com/v1/objects/", object, "/records")



    # Set filters
    if (!is.null(filter_field)) {
      # If dates are given, change to the correct format
      if (operator %in% c("is after", "if before", "is today")) {
        try(sapply(value, function(x) {
          format(as.Date(x), "%m/%d/%Y")
        }) -> value, silent = TRUE)
      }

      filters <- list(
        match = match,
        rules = data.frame(
          field = filter_field,
          operator = operator,
          value = value
        )
      )
      # Convert filters to JSON and URL encode
      filters_string <-
        toJSON(filters, auto_unbox = TRUE, pretty = TRUE)

      api_url <-
        paste0(api_url,
               '?rows_per_page=1000&filters=',
               URLencode(filters_string))
    }


    # Send the GET request
    result <- GET(
      api_url,
      add_headers(
        "X-Knack-Application-Id" = api_id,
        "X-Knack-REST-API-Key" = api_key
      )
    )

    # Retrieve and return the result
    data <- fromJSON(content(result, as = "text"))
    data$records

  }

# Testing
retrieve_filtered_data(
  "object_2",
  api_id = "61be439ed60d72001e68d749",
  api_key = ,
  filter_field = "field_6",
  match = "or",
  operator = "contains",
  value = "volvo"
)
