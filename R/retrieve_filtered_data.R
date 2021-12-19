#' Send Filtered Data Requests to Knack
#'
#' @param object A string containing the Knack object to pull data from. Ex: 'object_2'
#' @param api_id A string containing the Knack API ID.
#' @param api_key A string containing the Knack API key.
#' @param include_raw A logical stating whether raw fields should be included. Links are only included in raw fields.
#' @param filter_field A character vector of fields to filter. Can be one or more fields.
#' @param match A string containing either 'and' or 'or'. This will determine whether the records retrieved match all filters or at least one.
#' @param operator The character vector containing the operator for the filters. Options include:
#'     contains, does not contain, is, is not, starts with, ends with, is blank, is not blank,
#'     is during the current, is during the previous, is during the next, is before the previous,
#'     is after the next, is before, is after, is today, is today or before, is today or after,
#'     is before today, is after today, is before current time, is after current time.
#'     Note that dates must be in the format 'YYYY-MM-DD'
#' @param value A character vector containing the values the operator uses to filter by.
#'
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#' @importFrom jsonlite toJSON
#' @importFrom utils URLencode
#'
#' @return A data frame of filtered records.
#' @export
#'
#' @examples
#' retrieve_filtered_data('object_2',
#' api_id = '61be439ed60d72001e68d749',
#' api_key = "57632271-982d-40ac-acf6-245b7f940dca",
#' filter_field = 'field_6',
#' match = 'or',
#' operator = c('starts with','ends with'),
#' value = c('h','i'))
#'
#' retrieve_filtered_data("object_2",
#' api_id = "61be439ed60d72001e68d749",
#' api_key = "57632271-982d-40ac-acf6-245b7f940dca",
#' filter_field = "field_13",
#' match = "and",
#' operator = c("is after","if before"),
#' value = c("2021-12-2","2021-12-30"))
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

