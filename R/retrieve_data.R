
# This function takes three parameters: object, api_id, api_key
retrieve_data <-
  function(object,
           api_id,
           api_key) {
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
      clean_data <- data %>%
        select(!contains("raw")) %>%
        mutate_all(dropHTMLTags)
      return (clean_data)
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

    # Select only rows that are not "raw" and clean the html tags
    clean_data <- data %>%
      select(!contains("raw")) %>%
      mutate_all(dropHTMLTags)


    # Return the result
    return (clean_data)

  }

retrieve_data("object_5",
              "60a2a841ac3064001b208e21",
              "f7397923-c85f-4391-af98-463f47bb20dd")
