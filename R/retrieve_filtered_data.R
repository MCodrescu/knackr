



retrieve_filtered_data <-
  function(object,
           api_id,
           api_key,
           include_raw = FALSE,
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
    if (all(operater == c("is after", "if before"))) {
      date_start <- format(as.Date(value[1]), "%m/%d/%Y")
      date_end <- format(as.Date(value[2]), "%m/%d/%Y")
    }


    # Set filters
    filters <- list(match = "and",
                    rules = data.frame(
                      field = "field_170",
                      operator = c("is after", "is before"),
                      value = c(date_start, date_end)
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

    # Retrieve the result
    data <- fromJSON(content(result, as = "text"))
    data$records$field_170


  }
