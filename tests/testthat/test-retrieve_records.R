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
        retrieve_records(
          "mtcars"
        ),
        "Please set API credentials using set_credentials."
      )
    }
  )

  test_that(
    "retrieving all rows works correctly",
    {
      set_credentials(
        api_id = keyring::key_get("Knack Trial", "api_id"),
        api_key = keyring::key_get("Knack Trial", "api_key")
      )

      mtcars_knack <- retrieve_records(
        "mtcars"
      )

      row.names(mtcars_knack) <- NULL
      mtcars_no_rownames <- mtcars
      row.names(mtcars_no_rownames) <- NULL

      expect_equal(
        dplyr::arrange(
          mtcars_knack[, -c(1)],
          model
        ),
        dplyr::arrange(
          dplyr::mutate(
            dplyr::mutate(
              mtcars_no_rownames,
              model = row.names(mtcars)
            ),
            dplyr::across(
              .cols = dplyr::everything(),
              .fns = as.character
            )
          ),
          model
        )
      )

    }
  )

  test_that(
    "retreiving a limited number of records works correctly",
    {
      mtcars_knack <- retrieve_records(
        "mtcars",
        n_rows = 10
      )

      expect_true(
        is.data.frame(mtcars_knack)
      )

      expect_true(
        nrow(mtcars_knack) == 10
      )
    }
  )

  test_that(
    "retrieving over 1000 records works correctly",
    {

      random_data <- retrieve_records(
        "random_data"
      )

      expect_true(
        is.data.frame(random_data)
      )

      expect_true(
        nrow(random_data) == 3000
      )
    }
  )

  test_that(
    "a negative number of rows throws an error",
    {
      expect_error(
        retrieve_records(
          "random_data",
          -10
        )
      )
    }
  )

  test_that(
    "a table not found throws an error",
    {
      expect_error(
        retrieve_records(
          "non_existent_table"
        )
      )
    }
  )

}

