#' Update Records
#'
#' @param object A character string containing the object number. Ex: 'object_23'
#' @param record_id A character string of the record id. Ex: '61d87cf997ff7a33aaf44b6b'
#' @param data A data frame of the values to change. Column names should be the field ID's.
#'
#' @importFrom httr PUT
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom httr http_error
#' @importFrom httr http_status
#' @importFrom jsonlite toJSON
#' @importFrom jsonlite fromJSON
#' @importFrom magrittr %>%
#' @importFrom magrittr %$%
#' @importFrom dplyr filter
#' @importFrom dplyr pull
#'
#' @return A http status message.
#' @export
#'
#' @examples
#' \dontrun{
#' update_records("object_23",
#'                "61d87cf997ff7a33aaf44b6b",
#'                data.frame(field_170 = 2, field_168 = "New Data"))
#' }
update_records <- function(object, record_id, data) {

  # Check to see if Knack API credentials are set
  if (is.null(getOption("api_id")) |
      is.null(getOption("api_key"))) {
    return (print("Please set API credentials using set_credentials."))
  }

  # Get all objects
  objects <- list_objects()

  # Get all fields
  fields <- list_fields(object)
  fields_detailed <- list_fields(object, details = TRUE)

  # Retrieve the column names and keys
  column_labels <- fields$label
  column_keys <- fields$key

  # Get the label length of columns
  label_length <- length(column_labels)

  # Change the columns to undercase and replace
  # white space with underline
  column_labels <-
    str_replace_all(str_to_lower(column_labels), " ", "_")


  # Check to see if columns in the given data frame are actual fields in the object
  # rename columns to field number
  columns <- colnames(data)
  for (i in 1:length(columns)) {
    if (columns[i] %in% column_keys) {
      next
    } else if (columns[i] %in% column_labels) {
      columns[i] <- column_keys[match(columns[i], column_labels)]
      next
    } else{
      return(paste0("'", columns[i], "' is not a field in ", object))
    }
  }

  # Check if there are duplicates
  if (any(table(columns) > 1)) {
    return (paste("Duplicate fields found", names(table(columns)[table(columns) > 1])))
  }

  # Set the correct field names
  colnames(data) <- columns

  # Change filter fields of connected records to their id
  for (i in 1:length(columns)) {
    fields_detailed %>%
      filter(key == columns[i]) %>%
      pull(type) ->
      type


    if (type == "connection") {
      fields_detailed %>%
        filter(key == columns[i]) %$%
        relationship %$%
        object ->
        parent_object

      # Create a vector of column values
      column_name <- columns[i]
      value <- data[,column_name]

      # Get the records
      result <- GET(
        paste0(
          "https://api.knack.com/v1/objects/",
          parent_object,
          "/records?rows_per_page=",
          1000
        ),
        add_headers(
          "X-Knack-Application-Id" = getOption("api_id"),
          "X-Knack-REST-API-Key" = getOption("api_key")
        )
      )

      connected_data <- fromJSON(content(result, as = "text"))$records

      # Find where the connected record is
      j <- grep(value, connected_data)[1]
      x <- grep(value, connected_data[, j])[1]


      connected_id <- connected_data$id[x]

      # Plug in the connected record id
      value <- connected_id


      data[,column_name] <- value

    }
  }


  # Create JSON data
  data_json <- toJSON(as.list(data), auto_unbox = TRUE)

  # Create base url
  api_url <-
    paste0("https://api.knack.com/v1/objects/",
           object,
           "/records/",
           record_id)

  # Send http put request
  result <- PUT(
    api_url,
    add_headers(
      "X-Knack-Application-Id" = getOption("api_id"),
      "X-Knack-REST-API-Key" = getOption("api_key"),
      "Content-Type" = "application/json"
    ),
    body = data_json
  )

  #If error then stop and return error
  if (http_error(result)) {
    return (http_status(result)$message)
  }


  # Return the result
  http_status(result)$message

}
