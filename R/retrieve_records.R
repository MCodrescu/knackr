#' Retrieve Records
#'
#' @param table_name The name of the table to retrieve records from.
#' @param n_rows The number of rows to retrieve. The default is all rows.
#'
#' @importFrom jsonlite fromJSON
#' @importFrom httr content
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom dplyr contains
#' @importFrom dplyr everything
#' @importFrom dplyr bind_rows
#' @importFrom stats setNames
#'
#' @return A data frame of record values.
#' @export
retrieve_records <- function(
    table_name,
    n_rows = -1
){

  # Check to see if Knack API credentials are set
  if (is.null(getOption("api_id")) |
      is.null(getOption("api_key"))) {
    stop("Please set API credentials using set_credentials.")
  }

  # Get Table Key
  all_objects <- list_objects()
  table_key <- all_objects$key[which(all_objects$name == table_name)]
  if (identical(character(0), table_key)){
    stop(
      paste(
        "The table with name:",
        table_name,
        "was not found"
      )
    )
  }
  table_colnames <- list_fields(table_name)$label

  # Get Table Metadata
  table_slice <- jsonlite::fromJSON(
    httr::content(
      httr::GET(
        paste0(
          "https://api.knack.com/v1/objects/",
          table_key,
          "/records?rows_per_page=1",
          "&page=1"
        ),
        httr::add_headers(
          "X-Knack-Application-Id" = getOption("api_id"),
          "X-Knack-REST-API-Key" = getOption("api_key")
        )
      ),
      as = "text"
    )
  )

  # Grab Records
  if(n_rows == -1){
    total_records <- table_slice$total_records
    total_pages <- ceiling(total_records/1000)

    all_records_list <- lapply(
      seq_len(total_pages),
      function(i){
        Sys.sleep(0.3)
        jsonlite::fromJSON(
          httr::content(
            httr::GET(
              paste0(
                "https://api.knack.com/v1/objects/",
                 table_key,
                "/records?rows_per_page=",
                1000,
                "&page=",
                i
              ),
              httr::add_headers(
                "X-Knack-Application-Id" = getOption("api_id"),
                "X-Knack-REST-API-Key" = getOption("api_key")
              )
            ),
            as = "text"
          )
        )$records
      }
    )
  } else if (n_rows > 0){
    total_records <- n_rows
    total_pages <- ceiling(total_records/1000)
    records_remaining <- total_records

    all_records_list <- lapply(
      seq_len(total_pages),
      function(i){
        records_to_retrieve <- ifelse(
          records_remaining < 1000,
          records_remaining,
          1000
        )

        records_remaining <- records_remaining -
          records_to_retrieve

        jsonlite::fromJSON(
          httr::content(
            httr::GET(
              paste0(
                "https://api.knack.com/v1/objects/",
                table_key,
                "/records?rows_per_page=",
                records_to_retrieve,
                "&page=",
                i
              ),
              httr::add_headers(
                "X-Knack-Application-Id" = getOption("api_id"),
                "X-Knack-REST-API-Key" = getOption("api_key")
              )
            ),
            as = "text"
          )
        )$records
      }
    )
  } else {
    stop("n_rows must be greater than 0")
  }

  # Convert everything to character
  all_records_clean <- lapply(
    all_records_list,
    function(data){
      dplyr::mutate(
        dplyr::select(
          data,
          !dplyr::contains("Raw")
        ),
        dplyr::across(
          .cols = dplyr::everything(),
          .fns = as.character
        )
      )
    }
  )

  # Join all pages
  result <- stats::setNames(
    do.call(
      dplyr::bind_rows,
      all_records_clean
    ),
    nm = c("id", table_colnames)
  )

  return(result)

}
