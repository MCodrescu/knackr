



retrieve_filtered_data <-
  function(object,
           api_id,
           api_key,
           include_raw = FALSE,
           filter_field = NA,
           match = NA,
           operator = NA,
           value = NA) {
    # Set base url
    api_url <-
      paste0("https://api.knack.com/v1/objects/",
             object,
             "/records?rows_per_page=1000")


    # Change dates to correct format
    try(sapply(value, function(x) {
      format(as.Date(x), "%m/%d/%Y")
    }) -> value, silent = TRUE)


    if (all(sapply(c(filter_field, match, operator, value), is.na))) {

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
               '&filters=',
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
  api_key = "57632271-982d-40ac-acf6-245b7f940dca",
  filter_field = "field_10",
  match = "duh",
  operator = "something",
  value = "3"
)
