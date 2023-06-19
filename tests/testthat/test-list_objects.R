# You will need a trial knack account to run these tests
# The data sets needed can be created and uploaded with the following code
# https://docs.knack.com/docs/using-the-api
# readr::write_csv(
#   dplyr::mutate(
#     mtcars,
#     model = row.names(mtcars)
#   ),
#   "mtcars.csv"
# )
#
# example_data <-
#   wakefield::r_data_frame(
#     n = 3000,
#     wakefield::name(replace = TRUE),
#     wakefield::sex_inclusive(),
#     wakefield::marital(),
#     wakefield::dob(),
#     wakefield::education(),
#     wakefield::employment(),
#     wakefield::car(),
#     wakefield::political(),
#     wakefield::sat(),
#     wakefield::income(),
#     wakefield::state()
#   )
#
# readr::write_csv(
#   example_data,
#   "random_data.csv"
# )

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
    "objects are listed correctly",
    {
      set_credentials(
        api_id = keyring::key_get("Knack Trial", "api_id"),
        api_key = keyring::key_get("Knack Trial", "api_key")
      )

      objects <- list_objects()

      expect_equal(
        objects,
        structure(
          list(
            name = c("random_data", "mtcars"),
            key = c("object_1", "object_2")
          ),
          class = "data.frame",
          row.names = 1:2
        )
      )
    }
  )

}

