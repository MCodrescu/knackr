
#' Connect R and Knack
#'
#' @param object A string containing the knack object for which to retreive data ex: 'object_23'
#' @param api_id A string containing the API ID which can be found on the Knack Builder Site under API & Code
#' @param api_key A string containing the API Key which can be found on the Knack Builder Site under API & Code
#' @param include_raw A logical value saying whether or not raw field values should be included. Default is no. Note that links and image files are only included in raw fields.
#'
#' @return
#' @export
#'
#' @examples
retrieve_data <-
  function(object,
           api_id,
           api_key,
           include_raw = FALSE) {

    api_base <-
      paste0("https://api.knack.com/v1/objects/", object, "/records")

    # First determine the number of pages
    result <- httr::GET(
      paste0(api_base, "?rows_per_page=1000"),
      httr::add_headers(
        "X-Knack-Application-Id" = api_id,
        "X-Knack-REST-API-Key" = api_key
      )
    )
    n_pages <- jsonlite::fromJSON(httr::content(result, as = "text"))$total_pages
    data <- jsonlite::fromJSON(httr::content(result, as = "text"))$records

    # Create a function to clean html tags
    dropHTMLTags <- function(column) {
      if (any(grepl(">.+<", column))) {
        result <- stringr::str_remove_all(stringr::str_extract(column, ">.+<"), "[><]")
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
        dplyr::select(!dplyr::contains("raw")) %>%
        dplyr::mutate_all(dropHTMLTags)
      return (clean_data)
    }


    # If more than 1000 records, loop through the pages to get all the data
    for (i in 2:n_pages) {
      result <- httr::GET(
        paste0(api_base, "?rows_per_page=1000&page=", i),
        httr::add_headers(
          "X-Knack-Application-Id" = api_id,
          "X-Knack-REST-API-Key" = api_key
        )
      )
      data <- data %>%
        dplyr::bind_rows(jsonlite::fromJSON(httr::content(result, as = "text"))$records)

    }

    # Return raw data if specified
    if (include_raw) {
      return(data %>%
               dplyr::mutate_all(dropHTMLTags))
    }

    # Select only rows that are not "raw" and clean the html tags
    clean_data <- data %>%
      dplyr::select(!dplyr::contains("raw")) %>%
      dplyr::mutate_all(dropHTMLTags)


    # Return the result
    return (clean_data)

  }
