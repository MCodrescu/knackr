
<!-- README.md is generated from README.Rmd. Please edit that file -->

# knackr

<!-- badges: start -->

[![R-CMD-check](https://github.com/MCodrescu/knackr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MCodrescu/knackr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of knackr is to facilitate interaction with Knack Databases
using the [Knack](https://www.knack.com/) API. If you have any questions
or issues please submit a GitHub issue or contact me at
<m.codrescu@outlook.com>.

## Installation

You can install the development version of knackr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("MCodrescu/knackr")
```

## Set Credentials

Before interacting with the database, set your API credentials in the R
session.

``` r
knackr::set_credentials(
  api_id = keyring::key_get("Knack Trial", "api_id"),
  api_key = keyring::key_get("Knack Trial", "api_key")
)
```

## List Objects

You can list the objects present in a database by using the
`list_objects()` function.

``` r
knackr::list_objects()
#>          name      key
#> 1 random_data object_1
#> 2      mtcars object_2
```

## List Fields

You can also list the fields present in an object using `list_fields()`.

``` r
knackr::list_fields("mtcars")
#>    label      key required       type
#> 1    mpg field_14    FALSE short_text
#> 2    cyl field_15    FALSE short_text
#> 3   disp field_16    FALSE short_text
#> 4     hp field_17    FALSE short_text
#> 5   drat field_18    FALSE short_text
#> 6     wt field_19    FALSE short_text
#> 7   qsec field_20    FALSE short_text
#> 8     vs field_21    FALSE short_text
#> 9     am field_22    FALSE short_text
#> 10  gear field_23    FALSE short_text
#> 11  carb field_24    FALSE short_text
#> 12 model field_25    FALSE short_text
```

## Retrieve Records

You can retrieve records from a table using `retrieve_records()`.

``` r
result <- knackr::retrieve_records("mtcars")

dplyr::glimpse(result)
#> Rows: 32
#> Columns: 13
#> $ id    <chr> "648623e631c5670e85c570e4", "648623e631c5670e85c570de", "648623e…
#> $ mpg   <chr> "21.4", "15", "19.7", "15.8", "30.4", "26", "27.3", "19.2", "13.…
#> $ cyl   <chr> "4", "8", "6", "8", "4", "4", "4", "8", "8", "8", "8", "4", "4",…
#> $ disp  <chr> "121", "301", "145", "351", "95.1", "120.3", "79", "400", "350",…
#> $ hp    <chr> "109", "335", "175", "264", "113", "91", "66", "175", "245", "15…
#> $ drat  <chr> "4.11", "3.54", "3.62", "4.22", "3.77", "4.43", "4.08", "3.08", …
#> $ wt    <chr> "2.78", "3.57", "2.77", "3.17", "1.513", "2.14", "1.935", "3.845…
#> $ qsec  <chr> "18.6", "14.6", "15.5", "14.5", "16.9", "16.7", "18.9", "17.05",…
#> $ vs    <chr> "1", "0", "0", "0", "1", "0", "1", "0", "0", "0", "0", "1", "1",…
#> $ am    <chr> "1", "1", "1", "1", "1", "1", "1", "0", "0", "0", "0", "0", "1",…
#> $ gear  <chr> "4", "5", "5", "5", "5", "5", "4", "3", "3", "3", "3", "3", "4",…
#> $ carb  <chr> "2", "8", "6", "4", "2", "2", "1", "2", "4", "2", "2", "1", "1",…
#> $ model <chr> "Volvo 142E", "Maserati Bora", "Ferrari Dino", "Ford Pantera L",…
```

By default, `retrieve_records()` returns the entire object, but you can
specify the number of rows retrieved.

``` r
result <- knackr::retrieve_records("mtcars", n = 5)

dplyr::glimpse(result)
#> Rows: 5
#> Columns: 13
#> $ id    <chr> "648623e631c5670e85c570e4", "648623e631c5670e85c570de", "648623e…
#> $ mpg   <chr> "21.4", "15", "19.7", "15.8", "30.4"
#> $ cyl   <chr> "4", "8", "6", "8", "4"
#> $ disp  <chr> "121", "301", "145", "351", "95.1"
#> $ hp    <chr> "109", "335", "175", "264", "113"
#> $ drat  <chr> "4.11", "3.54", "3.62", "4.22", "3.77"
#> $ wt    <chr> "2.78", "3.57", "2.77", "3.17", "1.513"
#> $ qsec  <chr> "18.6", "14.6", "15.5", "14.5", "16.9"
#> $ vs    <chr> "1", "0", "0", "0", "1"
#> $ am    <chr> "1", "1", "1", "1", "1"
#> $ gear  <chr> "4", "5", "5", "5", "5"
#> $ carb  <chr> "2", "8", "6", "4", "2"
#> $ model <chr> "Volvo 142E", "Maserati Bora", "Ferrari Dino", "Ford Pantera L",…
```

If you are not sure how many records you have in a table you can use
`n_records()` to determine it.

``` r
knackr::n_records("mtcars")
#> [1] 32
```
