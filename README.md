
<!-- README.md is generated from README.Rmd. Please edit that file -->

# knackr

<!-- badges: start -->
<!-- badges: end -->

The goal of knackr is to facilitate the interaction with the
[Knack](https://www.knack.com/) API.

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
set_credentials(api_id = "61c0f74e19a523001ebd097a",
              api_key = "043bdc89-ec4d-4add-bcbb-bdda171192dd")
```

## List Objects

You can list the objects present in a database by using the
`list_objects()` function.

``` r
list_objects() %>%
  kable()
```

| name           | key      |
|:---------------|:---------|
| Contacts       | object_1 |
| Notes          | object_2 |
| Accounts       | object_4 |
| Sales Reps     | object_5 |
| Sales Managers | object_6 |

## List Fields

You can also list the fields present in an object using
`list_fields(object)` or list every field in the database using
`sapply`.

``` r
# List fields of a single object
list_fields("object_2") %>%
  kable()
```

| label                  | key      | type            |
|:-----------------------|:---------|:----------------|
| Date                   | field_34 | date_time       |
| Notes                  | field_2  | paragraph_text  |
| Add Task or Meeting    | field_35 | boolean         |
| Task or meeting        | field_47 | multiple_choice |
| Tasks or Meeting Types | field_42 | multiple_choice |
| Task/Meeting Due Date  | field_37 | date_time       |
| Contact                | field_22 | connection      |
| Task Status            | field_50 | multiple_choice |
| Task Update            | field_51 | paragraph_text  |
| Sales Rep              | field_58 | connection      |

``` r
# List fields of every object
objects <- list_objects()
database <- sapply(objects$key, list_fields)
```

## Retrieve Records

You can retrieve records from the database using `retrieve_records`. By
default, `retrieve_records` returns the entire object but you can
specify a subset of the data using filters. For a complete list of
possible filters refer to the [Knack
Documentation](https://docs.knack.com/docs/filters-field-types).

``` r
# Retrieve all records from an object
retrieve_records("object_2") %>%
  head() %>%
  kable()
```

| id                       | field_34   | field_2                                                    | field_35 | field_47 | field_42 | field_37                      | field_22   | field_50  | field_51 | field_58        |
|:-------------------------|:-----------|:-----------------------------------------------------------|:---------|:---------|:---------|:------------------------------|:-----------|:----------|:---------|:----------------|
| 61c0f751333f060721564c9b | 08/02/2017 | Confirmed through email that they are no longer interested | No       |          |          |                               | NA         | Pending   |          | Mary Smith      |
| 61c0f751333f060721564c99 | 07/26/2017 | Didn’t show up for first meeting                           | No       |          |          |                               | NA         | Pending   |          | Mary Smith      |
| 61c0f751333f060721564c97 | 04/20/2017 | Updated pipeline status to “Proposal”                      | No       |          |          |                               | Tim Smith  | Pending   |          | Johnny Gonzalez |
| 61c0f751333f060721564c95 | 07/02/2017 | Updated pipeline status to “Customer/Won”                  | No       |          |          |                               | Dave Myers | Pending   |          | Johnny Gonzalez |
| 61c0f751333f060721564c93 | 06/22/2017 | Discussed proposal details. Need to review with team.      | Yes      | Meeting  | Meetup   | 08/22/2017 10:30am to 11:45am | Dave Myers | Pending   |          | Johnny Gonzalez |
| 61c0f751333f060721564c91 | 03/30/2017 |                                                            | Yes      | Task     | Meetup   | 07/23/2017 6:00pm to 8:00pm   | Amir Kahn  | Completed |          | Mary Smith      |

### Retrieve records according to a single condition.

This example retrieves only those records that contain the word
‘Updated’ in field 2.

``` r
retrieve_records("object_2",
                  filter_field = "field_2",
                  operator = "contains",
                  value = "Updated") %>%
  kable()
```

| id                       | field_34   | field_2                                   | field_35 | field_47 | field_42 | field_37          | field_22       | field_50  | field_51 | field_58        |
|:-------------------------|:-----------|:------------------------------------------|:---------|:---------|:---------|:------------------|:---------------|:----------|:---------|:----------------|
| 61c0f751333f060721564c97 | 04/20/2017 | Updated pipeline status to “Proposal”     | No       |          |          |                   | Tim Smith      | Pending   |          | Johnny Gonzalez |
| 61c0f751333f060721564c95 | 07/02/2017 | Updated pipeline status to “Customer/Won” | No       |          |          |                   | Dave Myers     | Pending   |          | Johnny Gonzalez |
| 61c0f751333f060721564c8f | 05/02/2017 | Updated pipeline status to “Proposal”     | No       |          |          | 12/20/2021 4:36pm | Dave Myers     | Completed |          | Johnny Gonzalez |
| 61c0f751333f060721564c81 | 06/30/2017 | Updated pipeline status to “Proposal”     | No       |          |          | 12/20/2021 4:36pm | Linda DeCastro | Pending   |          | Johnny Gonzalez |

### Retrieve records within a data range.

This example retrieves only records with dates in field 34 between July
1, 2017 and August 31, 2017. Note that dates must be in the ‘YYYY-MM-DD’
format.

``` r
retrieve_records("object_2",
                  filter_field = "field_34",
                  operator = c("is after","is before"),
                  value = c('2017-07-01','2021-08-31')) %>%
  kable()
```

| id                       | field_34   | field_2                                                    | field_35 | field_47 | field_42 | field_37   | field_22       | field_50 | field_51 | field_58        |
|:-------------------------|:-----------|:-----------------------------------------------------------|:---------|:---------|:---------|:-----------|:---------------|:---------|:---------|:----------------|
| 61c0f751333f060721564c9b | 08/02/2017 | Confirmed through email that they are no longer interested | No       |          |          |            | NA             | Pending  |          | Mary Smith      |
| 61c0f751333f060721564c99 | 07/26/2017 | Didn’t show up for first meeting                           | No       |          |          |            | NA             | Pending  |          | Mary Smith      |
| 61c0f751333f060721564c95 | 07/02/2017 | Updated pipeline status to “Customer/Won”                  | No       |          |          |            | Dave Myers     | Pending  |          | Johnny Gonzalez |
| 61c0f751333f060721564c8b | 07/02/2017 | Want to be sure to communicate weekly.                     | Yes      | Meeting  | Meetup   | 07/06/2017 | Linda DeCastro | Pending  |          | Johnny Gonzalez |

### Retrieve records according to multiple field conditions

This example retrieves records according to two conditions: field 35 is
‘No’ and field 34 is after July 1, 2017. You can substitute ‘and’ with
‘or’ if you would like at least one condition to be true and not all.

``` r
retrieve_records("object_2",
                  filter_field = c("field_35","field_34"),
                  match = "and",
                  operator = c("is","is after"),
                  value = c("No","2017-07-01")) %>%
  kable()
```

| id                       | field_34   | field_2                                                    | field_35 | field_47 | field_42 | field_37 | field_22   | field_50 | field_51 | field_58        |
|:-------------------------|:-----------|:-----------------------------------------------------------|:---------|:---------|:---------|:---------|:-----------|:---------|:---------|:----------------|
| 61c0f751333f060721564c9b | 08/02/2017 | Confirmed through email that they are no longer interested | No       |          |          |          | NA         | Pending  |          | Mary Smith      |
| 61c0f751333f060721564c99 | 07/26/2017 | Didn’t show up for first meeting                           | No       |          |          |          | NA         | Pending  |          | Mary Smith      |
| 61c0f751333f060721564c95 | 07/02/2017 | Updated pipeline status to “Customer/Won”                  | No       |          |          |          | Dave Myers | Pending  |          | Johnny Gonzalez |
