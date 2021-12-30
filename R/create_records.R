

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
#' @importFrom utils setTxtProgressBar
#' @importFrom utils txtProgressBar
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

  # Set uploading estimate
  if (nrow(data) > 5){
    print.default(quote = FALSE, paste("Uploading... estimated:",round(nrow(data)*5/60, digits = 2),"minutes"))
  }

  # Create a progress bar
  pb <- txtProgressBar(min = 0,
                       max = nrow(data),
                       style = 3,
                       width = 50,
                       char = "=")


  # Determine field labels and keys from object
  fields <- list_fields(object)

  # Check to see if columns in the given data frame are actual fields in the object
  # rename columns to field number
  columns <- colnames(data)
  for (i in 1:length(columns)) {
    if (columns[i] %in% fields$key) {
      next
    } else if (columns[i] %in% fields$label) {
      columns[i] <- fields$key[match(columns[i], fields$label)]
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
      close(pb)
      return (http_status(result)$message)
    }

    # Add tick to progress bar
    setTxtProgressBar(pb, i)

  }

  # Return the result
  close(pb)
  http_status(result)$message

}
