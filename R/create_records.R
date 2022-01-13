

#' Create Records
#'
#' @param object A string containing the object number. Ex: 'object_5'
#' @param data A dataframe with the data to upload. Column names should match field keys or labels.
#'
#' @importFrom httr POST
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
#' @return A status message. Ex: 'Success: (200) OK'
#' @export
#'
#' @examples
#' \dontrun{
#' # Example dataframe.
#' # Column names can be field numbers or labels.
#' data <- data.frame(Age = c(46,17,80),
#'                    Income = c(114, 63, 45.5),
#'                    HoursWk = c(60, 40, 42),
#'                    Language = c(0, 1, 0)
#'                    )
#'
#'# This process may take some time to complete.
#' create_records('object_5', data)
#' }
create_records <- function(object, data) {

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
      values <- data[,column_name]

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

      for (v in 1:length(values)){

        # Find where the connected record is
        j <- grep(values[v], connected_data)[1]
        x <- grep(values[v], connected_data[, j])[1]

        connected_id <- connected_data$id[x]

        # Plug in the connected record id
        values[v] <- connected_id
      }

      data[,column_name] <- values

    }
  }


  # Post data one record at a time
  for (i in 1:nrow(data)) {
    data_json <- toJSON(as.list(data[i,]), auto_unbox = TRUE)

    # Post data to knack
    api_url <-
      paste0("https://api.knack.com/v1/objects/", object, "/records")
    result <- POST(
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

  }

  # Return the result
  http_status(result)$message

}
