


# Function parameters: object, api_id, api_key, include_raw
# object - which knack object should be retrieved
# api_id/api_key - unique authentication identifiers
# include_raw - should raw values be included? default is no.
#   links and image files are only included with raw data
retrieve_data <-
  function(object,
           api_id,
           api_key,
           include_raw = FALSE) {
    # Load dependent packages
    library(jsonlite)
    library(httr)
    library(dplyr)
    library(stringr)

    api_base <-
      paste0("https://api.knack.com/v1/objects/", object, "/records")

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

    # Create a function to clean html tags
    dropHTMLTags <- function(column) {
      if (any(grepl(">.+<", column))) {
        result <- str_remove_all(str_extract(column, ">.+<"), "[><]")
      } else {
        result <- column
      }
      result
    }

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
        paste0(api_base, "?rows_per_page=1000&page=", i),
        add_headers(
          "X-Knack-Application-Id" = api_id,
          "X-Knack-REST-API-Key" = api_key
        )
      )
      data <- data %>%
        bind_rows(fromJSON(content(result, as = "text"))$records)

    }

    # Return raw data if specified
    if (include_raw) {
      return(data %>%
               mutate_all(dropHTMLTags))
    }

    # Select only rows that are not "raw" and clean the html tags
    clean_data <- data %>%
      select(!contains("raw")) %>%
      mutate_all(dropHTMLTags)


    # Return the result
    return (clean_data)

  }
