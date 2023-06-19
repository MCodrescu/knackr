api_working <- tryCatch({
  set_credentials(
    api_id = keyring::key_get("Knack Trial", "api_id"),
    api_key = keyring::key_get("Knack Trial", "api_key")
  )

  response <- GET(
    "https://api.knack.com/v1/objects/",
    add_headers(
      "X-Knack-Application-Id" = getOption("api_id"),
      "X-Knack-REST-API-Key" = getOption("api_key")
    )
  )

  response$status_code == 200

}, error = function(error){

  FALSE
})

if (api_working){
  test_that(
    "setting api credentials is required",
    {
      options(api_id = NULL)
      options(api_key = NULL)

      expect_error(
        list_objects(),
        "Please set API credentials using set_credentials."
      )
    }
  )

  test_that(
    "the correct number of records are returned",
    {
      set_credentials(
        api_id = keyring::key_get("Knack Trial", "api_id"),
        api_key = keyring::key_get("Knack Trial", "api_key")
      )

      expect_equal(
        n_records("mtcars"),
        32
      )

      expect_equal(
        n_records("random_data"),
        3000
      )
    }
  )

  test_that(
    "a table not found throws an error",
    {
      expect_error(
        n_records(
          "non_existent_table"
        )
      )
    }
  )

}

