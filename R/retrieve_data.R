
# This function takes three parameters: knack base url, api,id, and api_key
# The base url should specify which records are being retrieved
retrieve_data <-
  function(base_url,
           api_id,
           api_key
           ) {

    # Load dependent packages
    library(jsonlite)
    library(httr)
    library(dplyr)
    library(stringr)

    # First determine the number of pages
    result <- GET(
      paste0(api_base, "?rows_per_page=1000"),
      add_headers(
        "X-Knack-Application-Id" = api_id,
        "X-Knack-REST-API-Key" = api_key
      )
    )
    n_pages <- fromJSON(content(result, as = "text"))$total_pages
    data <- fromJSON(content(result, as = "text"))$records

    # If there is only one page then stop
    if (n_pages == 1) {
      return (data)
    }


    # Otherwise, loop through the pages to get all the data
    for (i in 2:n_pages) {
      result <- GET(
        paste0(api_base, "?rows_per_page=1000&page=", i),
        add_headers(
          "X-Knack-Application-Id" = api_id,
          "X-Knack-REST-API-Key" = api_key
        )
      )
      data <- data %>%
        bind_rows(fromJSON(content(result, as = "text"))$records)

    }

    # Create a function to clean html tags
    dropHTMLTags <- function(column) {
      if (any(grepl(">.+<", column))) {
        result <- str_remove_all(str_extract(column, ">.+<"), "[><]")
      } else {
        result <- column
      }
      result
    }

    # Select only rows that are not "raw" and clean the html tags
    clean_data <- data %>%
      select(!contains("raw")) %>%
      mutate_all(dropHTMLTags)


    # Return the result
    return (clean_data)

  }

