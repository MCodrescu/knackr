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

    # If dates are given, change to the correct format
    if (operator %in% c("is after", "if before", "is today")) {
      try(sapply(value, function(x) {
        format(as.Date(x), "%m/%d/%Y")
      }) -> value, silent = TRUE)
    }

    # Set filters
    filters <- list(match = match,
                    rules = data.frame(
                      field = filter_field,
                      operator = operator,
                      value = value
                    ))

    # Convert filters to JSON and URL encode
    filters_string <-
      toJSON(filters, auto_unbox = TRUE, pretty = TRUE)
    api_url <-
      paste0(api_url,
             '?rows_per_page=1000&filters=',
             URLencode(filters_string))

    # Send the GET request
    result <- GET(
      api_url,
      add_headers(
        "X-Knack-Application-Id" = "60a2a841ac3064001b208e21",
        "X-Knack-REST-API-Key" = "f7397923-c85f-4391-af98-463f47bb20dd"
      )
    )

    # Retrieve and return the result
    data <- fromJSON(content(result, as = "text"))
    data$records

  }

# Testing
retrieve_filtered_data("object_2",
                       api_id = "61be439ed60d72001e68d749",
                       api_key = "57632271-982d-40ac-acf6-245b7f940dca",
                       filter_field = "field_6",
                       match = "and",
                       operator = "contains",
                       value = "volvo")





