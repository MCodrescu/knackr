
retrieve_data <- function(base_url, api_id, api_key, field = NULL, operator = NULL, value = NULL) {

  # Load dependent packages
  library(jsonlite)
  library(httr)

  if (!is.null(value)){
    # Check to see if dates are provided for value
    tryCatch(
      expr = as.Date('2021212'),
      error = function(e){return "Error"}
    )
  }
  # Set boundaries for date range
  date_start <- format(as.Date('2021-11-01'), "%m/%d/%Y")
  date_end <- format(as.Date('2021-11-30'), "%m/%d/%Y")

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

# Get data from knack job cost accounting
api_url <- "https://api.knack.com/v1/objects/object_23/records"
