

set_credentials("61c0f74e19a523001ebd097a",
                "043bdc89-ec4d-4add-bcbb-bdda171192dd")


create_records <- function(object, data){

  # Determine field labels and keys from object
  fields <- list_fields(object)

  # Check to see if columns in the given data frame are actual fields in the object
  # rename columns to field number
  columns <- colnames(data)
  for (i in 1:length(columns)){
    if (columns[i] %in% fields$key){
      next
    } else if(columns[i] %in% fields$label){
      columns[i] <- fields$key[match(columns[i], fields$label)]
      next
    } else{
      return(paste(columns[i], "is not included in",object))
    }
  }

  # Check if there are duplicates
  if (any(table(columns) > 1)){
    return (paste("Duplicate fields found",names(table(columns)[table(columns) > 1])))
  }

  # Set the correct field names
  colnames(data) <- columns

  # Change the data frame to json
  data <- gsub("\\[*\\]*", "", toJSON(data))

  return(data)

  # Post data to knack
  api_url <- paste0("https://api.knack.com/v1/objects/",object,"/records")
  result <- POST(
    api_url,
    add_headers(
      "X-Knack-Application-Id" = getOption("api_id"),
      "X-Knack-REST-API-Key" = getOption("api_key"),
      "Content-Type" = "application/json"
    ),
    body = data
  )

  # Return the result
  http_status(result)

}

data <- toJSON(list(field_69 = 1, field_70 = 46), auto_unbox = TRUE)

result <- POST("https://api.knack.com/v1/objects/object_7/records",
     add_headers("X-Knack-Application-Id" = getOption("api_id"),
                 "X-Knack-REST-API-Key" = getOption("api_key"),
                 "Content-Type" = "application/json"),
     body = data)


http_status(result)
retrieve_records("object_7")

