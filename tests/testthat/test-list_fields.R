# See test-list_objects() for requirements for this test

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
    "fields are returned correctly",
    {
      set_credentials(
        api_id = keyring::key_get("Knack Trial", "api_id"),
        api_key = keyring::key_get("Knack Trial", "api_key")
      )

      expect_equal(
        list_fields("mtcars"),
        structure(
          list(
            label = c(
              "mpg", "cyl", "disp", "hp", "drat",
              "wt", "qsec", "vs", "am", "gear",
              "carb", "model"
            ),
            key = c(
              "field_14", "field_15", "field_16",
              "field_17", "field_18", "field_19",
              "field_20", "field_21", "field_22",
              "field_23", "field_24", "field_25"
            ),
            required = c(
              FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
              FALSE, FALSE, FALSE, FALSE, FALSE
            ),
            type = c(
              "short_text", "short_text", "short_text",
              "short_text", "short_text", "short_text",
              "short_text", "short_text", "short_text", "short_text",
              "short_text", "short_text"
            )
          ),
          class = "data.frame",
          row.names = c(NA, 12L)
        )
      )
    }
  )
}




