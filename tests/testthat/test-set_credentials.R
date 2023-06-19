test_that(
  "credentials set correctly",
  {
    set_credentials(
      api_id = "123",
      api_key = "234"
    )

    expect_true(
      getOption("api_id") == "123"
    )

    expect_true(
      getOption("api_key") == "234"
    )

  }
)

# Reset
options(api_id = NULL)
options(api_key = NULL)
