
#' Connect R and Knack
#'
#' @param object A string containing the knack object for which to retreive data ex: 'object_23'
#' @param api_id A string containing the API ID which can be found on the Knack Builder Site under API & Code
#' @param api_key A string containing the API Key which can be found on the Knack Builder Site under API & Code
#' @param include_raw A logical value saying whether or not raw field values should be included. Default is no. Note that links and image files are only included in raw fields.
#'
#' @importFrom magrittr %>%
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_extract
#' @importFrom dplyr select
#' @importFrom dplyr mutate_all
#' @importFrom dplyr contains
#' @importFrom dplyr bind_rows
#'
#' @return A data frame (tibble)
#' @export
#'
#' @examples
#' \dontrun{
#' retrieve_data('object_23','YOUR_API_ID','YOUR_API_KEY')
#' }

retrieve_data <-
  function(object,
           api_id,
           api_key,
           include_raw = FALSE) {

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
