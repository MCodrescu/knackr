#' Retrieve Records From Knack
#'
#' @param object A string containing the Knack object to pull data from. Ex: 'object_2'
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
#' @importFrom magrittr %>%
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#' @importFrom jsonlite toJSON
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_extract
#' @importFrom utils URLencode
#' @importFrom dplyr select
#' @importFrom dplyr mutate_all
#' @importFrom dplyr contains
#' @importFrom dplyr bind_rows
#'
#' @return A data frame of filtered records.
#' @export
#'
#' @examples
#'
retrieve_records <-
  function(object,
           include_raw = FALSE,
           filter_field = NA,
           match = NA,
           operator = NA,
           value = NA) {
    # Check to see if Knack API credentials are set
    if (is.null(getOption("api_id")) |
        is.null(getOption("api_key"))) {
      return (print("Please set API credentials using set_credentials."))
    }

    # Set base url
    api_url <-
      paste0("https://api.knack.com/v1/objects/",
             object,
             "/records?rows_per_page=1000")


    # Create a function to clean html tags
    dropHTMLTags <- function(column) {
      if (any(grepl(">.+<", column))) {
        result <- str_remove_all(str_extract(column, ">.+<"), "[><]")
      } else {
        result <- column
      }
      result
    }

    # Change dates to correct format
    try(sapply(value, function(x) {
      format(as.Date(x), "%m/%d/%Y")
    }) -> value, silent = TRUE)


    # Check to see if any filters are given.
    if (all(sapply(c(filter_field, match, operator, value), is.na))) {
      # Create filters list
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
        toJSON(filters, auto_unbox = TRUE)

      # Attach filters to the url
      api_url <-
        paste0(api_url,
               '&filters=',
               URLencode(filters_string))
    }

    # Determine the number of pages
    result <- GET(
      api_url,
      add_headers(
        "X-Knack-Application-Id" = getOption("api_id"),
        "X-Knack-REST-API-Key" = getOption("api_key")
      )
    )
    n_pages <- fromJSON(content(result, as = "text"))$total_pages
    data <- fromJSON(content(result, as = "text"))$records


    # If there is only one page then stop
    if (n_pages == 1) {
      # If raw is to be included
      if (include_raw) {
        return (data)
      }
      # Return the cleaned data
      clean_data <- data %>%
        select(!contains("raw")) %>%
        mutate_all(dropHTMLTags)
      return (clean_data)
    }

    # If more than 1000 records, loop through the pages to get all the data
    for (i in 2:n_pages) {
      result <- GET(
        paste0(api_url, "&page=", i),
        add_headers(
          "X-Knack-Application-Id" = getOption("api_id"),
          "X-Knack-REST-API-Key" = getOption("api_key")
        )
      )
      data <- data %>%
        bind_rows(fromJSON(content(result, as = "text"))$records)

    }

    # Return the result
    data$records

  }