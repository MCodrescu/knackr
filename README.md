
<!-- README.md is generated from README.Rmd. Please edit that file -->

# knackr

<!-- badges: start -->
<!-- badges: end -->

The goal of knackr is to facilitate interaction with Knack Databases
using the [Knack](https://www.knack.com/) API.

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
| ACS            | object_7 |

## List Fields

You can also list the fields present in an object using
`list_fields(object)` or list every field in the database using
`sapply`. `list_fields` will automatically change field labels to under
case without white space.

``` r
# List fields of a single object
list_fields("object_2") %>%
  kable()
```

| label                  | key      | type            |
|:-----------------------|:---------|:----------------|
| date                   | field_34 | date_time       |
| notes                  | field_2  | paragraph_text  |
| add_task_or_meeting    | field_35 | boolean         |
| task_or_meeting        | field_47 | multiple_choice |
| tasks_or_meeting_types | field_42 | multiple_choice |
| task/meeting_due_date  | field_37 | date_time       |
| contact                | field_22 | connection      |
| task_status            | field_50 | multiple_choice |
| task_update            | field_51 | paragraph_text  |
| sales_rep              | field_58 | connection      |

``` r
# List fields of every object
objects <- list_objects()
database <- sapply(objects$key, list_fields)
```

## Retrieve Records

You can retrieve records from the database using `retrieve_records`. By
default, `retrieve_records` returns the entire object but you can
specify a subset of the data using filters or limit the total number of
records retrieved. For a complete list of possible filters refer to the
[Knack Documentation](https://docs.knack.com/docs/filters-field-types).

``` r
# Retrieve the first 10 records from an object
retrieve_records("object_2", limit = 10) %>%
  kable()
```

| id                       | date       | notes                                 | add_task_or_meeting | task_or_meeting | tasks_or_meeting_types | task/meeting_due_date | contact        | task_status | task_update | sales_rep       |
|:-------------------------|:-----------|:--------------------------------------|:--------------------|:----------------|:-----------------------|:----------------------|:---------------|:------------|:------------|:----------------|
| 61e08ee5b3a1c7a44a6f825f | 06/13/2017 | Demo went really well                 | Yes                 | Meeting         | Tech Demo              |                       | Linda DeCastro | Completed   |             | Johnny Gonzalez |
| 61e08586100f415129d8f8f7 | 06/30/2017 | Updated pipeline status to “Proposal” | Yes                 |                 |                        | 12/20/2021 4:36pm     | Linda DeCastro | Pending     |             | Johnny Gonzalez |
| 61c69d75d069eb325874bb65 | 12/24/2021 |                                       | No                  |                 |                        | 12/24/2021 11:26pm    | NA             | Pending     |             | NA              |
| 61c69d279c4fd60bbda99aa2 | 12/24/2021 |                                       | No                  |                 |                        | 12/24/2021 11:25pm    | NA             | Pending     |             | NA              |
| 61c69bee52122572e7c2add8 | 12/24/2021 |                                       | No                  |                 |                        | 12/24/2021 11:19pm    | NA             | Pending     |             | NA              |
| 61c69287ca530fd77088f4f4 | 12/24/2021 |                                       | No                  |                 |                        | 12/24/2021 10:39pm    | NA             | Pending     |             | NA              |
| 61c541001bfb59176d641ee7 | 12/23/2021 | Confirmed that this worked!           | No                  |                 |                        | 12/23/2021 10:39pm    | NA             | Pending     |             | NA              |
| 61c54085445feb9ad0df8dac | 12/23/2021 |                                       | No                  |                 |                        | 12/23/2021 10:37pm    | NA             | Pending     |             | NA              |
| 61c53fd58f498f2fb00cdfbb | 12/23/2021 |                                       | No                  |                 |                        | 12/23/2021 10:34pm    | NA             | Pending     |             | NA              |
| 61c53f286f9bfb4b67f251d4 | 12/23/2021 |                                       | No                  |                 |                        | 12/23/2021 10:31pm    | NA             | Pending     |             | NA              |

### Retrieve records according to a single condition.

This example retrieves only those records that contain the word
‘Updated’ in the `notes` field.

``` r
retrieve_records("object_2",
                 "notes",
                 "Updated",
                 "contains") %>%
  kable()
```

| id                       | date       | notes                                     | add_task_or_meeting | task_or_meeting | tasks_or_meeting_types | task/meeting_due_date | contact        | task_status | task_update | sales_rep       |
|:-------------------------|:-----------|:------------------------------------------|:--------------------|:----------------|:-----------------------|:----------------------|:---------------|:------------|:------------|:----------------|
| 61e08586100f415129d8f8f7 | 06/30/2017 | Updated pipeline status to “Proposal”     | Yes                 |                 |                        | 12/20/2021 4:36pm     | Linda DeCastro | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c97 | 04/20/2017 | Updated pipeline status to “Proposal”     | No                  |                 |                        |                       | Tim Smith      | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c95 | 07/02/2017 | Updated pipeline status to “Customer/Won” | No                  |                 |                        |                       | Dave Myers     | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c8f | 05/02/2017 | Updated pipeline status to “Proposal”     | No                  |                 |                        | 12/20/2021 4:36pm     | Dave Myers     | Completed   |             | Johnny Gonzalez |

### Retrieve records within a data range.

This example retrieves only records with dates in the `date` field
between July 1, 2017 and August 31, 2017.

``` r
retrieve_records("object_2",
                 c("date", "date"),
                 c('2017-07-01', '2021-08-31'),
                 c("is after", "is before")) %>%
  kable()
```

| id                       | date       | notes                                                      | add_task_or_meeting | task_or_meeting | tasks_or_meeting_types | task/meeting_due_date | contact        | task_status | task_update | sales_rep       |
|:-------------------------|:-----------|:-----------------------------------------------------------|:--------------------|:----------------|:-----------------------|:----------------------|:---------------|:------------|:------------|:----------------|
| 61c0f751333f060721564c9b | 08/02/2017 | Confirmed through email that they are no longer interested | No                  |                 |                        |                       | NA             | Pending     |             | Mary Smith      |
| 61c0f751333f060721564c99 | 07/26/2017 | Didn’t show up for first meeting                           | No                  |                 |                        |                       | NA             | Pending     |             | Mary Smith      |
| 61c0f751333f060721564c95 | 07/02/2017 | Updated pipeline status to “Customer/Won”                  | No                  |                 |                        |                       | Dave Myers     | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c8b | 07/02/2017 | Want to be sure to communicate weekly.                     | Yes                 | Meeting         | Meetup                 | 07/06/2017            | Linda DeCastro | Pending     |             | Johnny Gonzalez |

### Retrieve records according to multiple field conditions

This example retrieves records according to two conditions:
`add_task_or_meeting` is ‘No’ and `date` is after July 1, 2017. You can
substitute ‘and’ with ‘or’ if you would like at least one condition to
be true and not all.

``` r
retrieve_records("object_2",
                 c("add_task_or_meeting","date"),
                 c("No","2017-07-01"),
                 c("is","is after"),
                 match = "or") %>%
  kable()
```

| id                       | date       | notes                                                      | add_task_or_meeting | task_or_meeting | tasks_or_meeting_types | task/meeting_due_date | contact        | task_status | task_update | sales_rep       |
|:-------------------------|:-----------|:-----------------------------------------------------------|:--------------------|:----------------|:-----------------------|:----------------------|:---------------|:------------|:------------|:----------------|
| 61c69d75d069eb325874bb65 | 12/24/2021 |                                                            | No                  |                 |                        | 12/24/2021 11:26pm    | NA             | Pending     |             | NA              |
| 61c69d279c4fd60bbda99aa2 | 12/24/2021 |                                                            | No                  |                 |                        | 12/24/2021 11:25pm    | NA             | Pending     |             | NA              |
| 61c69bee52122572e7c2add8 | 12/24/2021 |                                                            | No                  |                 |                        | 12/24/2021 11:19pm    | NA             | Pending     |             | NA              |
| 61c69287ca530fd77088f4f4 | 12/24/2021 |                                                            | No                  |                 |                        | 12/24/2021 10:39pm    | NA             | Pending     |             | NA              |
| 61c541001bfb59176d641ee7 | 12/23/2021 | Confirmed that this worked!                                | No                  |                 |                        | 12/23/2021 10:39pm    | NA             | Pending     |             | NA              |
| 61c54085445feb9ad0df8dac | 12/23/2021 |                                                            | No                  |                 |                        | 12/23/2021 10:37pm    | NA             | Pending     |             | NA              |
| 61c53fd58f498f2fb00cdfbb | 12/23/2021 |                                                            | No                  |                 |                        | 12/23/2021 10:34pm    | NA             | Pending     |             | NA              |
| 61c53f286f9bfb4b67f251d4 | 12/23/2021 |                                                            | No                  |                 |                        | 12/23/2021 10:31pm    | NA             | Pending     |             | NA              |
| 61c0f751333f060721564c9b | 08/02/2017 | Confirmed through email that they are no longer interested | No                  |                 |                        |                       | NA             | Pending     |             | Mary Smith      |
| 61c0f751333f060721564c99 | 07/26/2017 | Didn’t show up for first meeting                           | No                  |                 |                        |                       | NA             | Pending     |             | Mary Smith      |
| 61c0f751333f060721564c97 | 04/20/2017 | Updated pipeline status to “Proposal”                      | No                  |                 |                        |                       | Tim Smith      | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c95 | 07/02/2017 | Updated pipeline status to “Customer/Won”                  | No                  |                 |                        |                       | Dave Myers     | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c8f | 05/02/2017 | Updated pipeline status to “Proposal”                      | No                  |                 |                        | 12/20/2021 4:36pm     | Dave Myers     | Completed   |             | Johnny Gonzalez |
| 61c0f751333f060721564c8b | 07/02/2017 | Want to be sure to communicate weekly.                     | Yes                 | Meeting         | Meetup                 | 07/06/2017            | Linda DeCastro | Pending     |             | Johnny Gonzalez |

### Retrieve connected records

You can also set filters according to connected record fields without a
problem. Notice that field 22, `contact`, is a connection. We can see
what object it connects to using
`list_fields("object_2", details = TRUE)` and the `unnest` function from
the `tidyr` package.

``` r
list_fields("object_2", details = TRUE) %>%
  tidyr::unnest(relationship) %>% 
  kable()
```

| label                  | key      | required | type            | choices                                                                                        | belongs_to | has | object   |
|:-----------------------|:---------|:---------|:----------------|:-----------------------------------------------------------------------------------------------|:-----------|:----|:---------|
| date                   | field_34 | FALSE    | date_time       | NULL                                                                                           | NA         | NA  | NA       |
| notes                  | field_2  | FALSE    | paragraph_text  | NULL                                                                                           | NA         | NA  | NA       |
| add_task_or_meeting    | field_35 | FALSE    | boolean         | NULL                                                                                           | NA         | NA  | NA       |
| task_or_meeting        | field_47 | FALSE    | multiple_choice | Task , Meeting                                                                                 | NA         | NA  | NA       |
| tasks_or_meeting_types | field_42 | FALSE    | multiple_choice | Follow Up Email, Phone Call , Lunch Meeting , Tech Demo , Meetup , Conference , Something else | NA         | NA  | NA       |
| task/meeting_due_date  | field_37 | FALSE    | date_time       | NULL                                                                                           | NA         | NA  | NA       |
| contact                | field_22 | FALSE    | connection      | NULL                                                                                           | many       | one | object_1 |
| task_status            | field_50 | FALSE    | multiple_choice | Pending , Completed                                                                            | NA         | NA  | NA       |
| task_update            | field_51 | FALSE    | paragraph_text  | NULL                                                                                           | NA         | NA  | NA       |
| sales_rep              | field_58 | FALSE    | connection      | NULL                                                                                           | many       | one | object_5 |

We can see that `contact` connects with object_1. We can retrieve the
records of object_1 to see what it holds.

``` r
retrieve_records("object_1") %>%
  kable()
```

| id                       | contact        | lead_referral_source    | date_of_initial_contact | title                | company          | industry     | address                                         | phone            | email                   | status       | website                   | linkedin_profile | background_info                                        | sales_rep       | rating | project_type                        | project_description                                                                               | proposal_due_date | budget     | deliverables                   |
|:-------------------------|:---------------|:------------------------|:------------------------|:---------------------|:-----------------|:-------------|:------------------------------------------------|:-----------------|:------------------------|:-------------|:--------------------------|:-----------------|:-------------------------------------------------------|:----------------|:-------|:------------------------------------|:--------------------------------------------------------------------------------------------------|:------------------|:-----------|:-------------------------------|
| 61c0f751333f060721564c7b | Linda DeCastro | Conference              | 06/11/2017              | Regional Sales Mgr   | Pillsbury        | Retail Foods | 44 Reading Rd<br />Flourtown, NJ 39485          | \(555\) 555-5555 | <linda@pillsbury.com>   | Proposal     | www.pillsbury.com         | www.sample.com   | New territory MGR                                      | Johnny Gonzalez | 3.00   | New Packaging for Cookie products   | Design new cookie packaging for new line of Sugar Free cookies.                                   | 07/31/2017        | $45,000.00 | 6 Proofs, multiple assets      |
| 61c0f751333f060721564c79 | Sally Jane     | CES Conference          | 04/09/2017              | COO                  | Facetech         | Tech         | 123 Tech Blvd<br />Menlo Park, CA 12345         | \(321\) 321-1122 | <sally@facetech.com>    | Lead         | <http://www.facetech.com> | www.sample.com   | Great contact, has a really great roadmap.             | Johnny Gonzalez | 5.00   |                                     |                                                                                                   |                   | $30,000.00 |                                |
| 61c0f751333f060721564c7d | Amir Kahn      | www.google .com         | 05/12/2017              | PR Director          | Barnes and Wells | PR           | 52 Broadway<br />New York, NY 12345             | \(234\) 432-2234 | <amir@pr.com>           | Lead         | www.pr.com                | www.sample.com   | 4 years as PR Dir. Knows the biz and has wide network. | Mary Smith      | 5.00   |                                     |                                                                                                   |                   |            |                                |
| 61c0f751333f060721564c77 | Dave Myers     | Mack Truck Partner Site | 03/11/2017              | DEF Sales            | DEF Fluids       | Auto         | 456 Diesel St<br />Philadelphia, PA 19308       | \(765\) 765-7755 | <dave@def.com>          | Customer/Won | www.def.com               | www.sample.com   | 19 years in biz                                        | Johnny Gonzalez | 2.50   |                                     |                                                                                                   |                   |            |                                |
| 61c0f750333f060721564c75 | Tim Smith      | www.google.com          | 02/08/2017              | Supply Chain Manager | Levis            | Apparel      | 1 Blue Jean St.<br />Corduroy, CO 12345         | \(321\) 321-4321 | <tim@levis.com>         | Proposal     | www.levis.com             | www.sample.com   | Jeans and apparel for eastern U.S.<br />               | Johnny Gonzalez | 3.50   | Shelf talkers; kiosk style displays | Set up shelf talkers for stock shelves with an end of aisle kiosk detailing the history of Levis. | 07/09/2017        | $40,000.00 | 10k shelf talkers, 1500 kiosks |
| 61c0f751333f060721564c7f | Sarah Williams | google.com              | 07/02/2017              | VP of Operations     | H&E Analytics    | Tech         | 7768 West Drive Of Oakley<br />Fresno, CA 93102 | \(219\) 504-8872 | <sarah@heanalytics.com> | Lead         | www.heanalytics.com       | www.sample.com   | Running operations for five years.                     | Mary Smith      | 0.00   |                                     |                                                                                                   |                   |            |                                |

We can now use any of the above fields when we create filters for
object_2. For example, let’s search object 2 for only those records
connected to ‘Linda DeCastro’.

``` r
retrieve_records("object_2",
                 "contact",
                 "Linda DeCastro") %>%
  kable()
```

| id                       | date       | notes                                  | add_task_or_meeting | task_or_meeting | tasks_or_meeting_types | task/meeting_due_date | contact        | task_status | task_update | sales_rep       |
|:-------------------------|:-----------|:---------------------------------------|:--------------------|:----------------|:-----------------------|:----------------------|:---------------|:------------|:------------|:----------------|
| 61e08ee5b3a1c7a44a6f825f | 06/13/2017 | Demo went really well                  | Yes                 | Meeting         | Tech Demo              |                       | Linda DeCastro | Completed   |             | Johnny Gonzalez |
| 61e08586100f415129d8f8f7 | 06/30/2017 | Updated pipeline status to “Proposal”  | Yes                 |                 |                        | 12/20/2021 4:36pm     | Linda DeCastro | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c8b | 07/02/2017 | Want to be sure to communicate weekly. | Yes                 | Meeting         | Meetup                 | 07/06/2017            | Linda DeCastro | Pending     |             | Johnny Gonzalez |

## Update Records

We can update records in the knack database using the `update_records`
function. We supply the object number, record id, and a data frame of
new values to update. For example, suppose we want to change the last
record in the previous example. We can do that in the following way:

``` r
update_records("object_2",
               "61c0f751333f060721564c85",
               data.frame(add_task_or_meeting = "Yes"))
#> [1] "Success: (200) OK"
```

The result is an http status message. We see that the update was
successful but let’s pull the record again to double check.

``` r
retrieve_records("object_2",
                 "contact",
                 "Linda DeCastro") %>%
  kable()
```

| id                       | date       | notes                                  | add_task_or_meeting | task_or_meeting | tasks_or_meeting_types | task/meeting_due_date | contact        | task_status | task_update | sales_rep       |
|:-------------------------|:-----------|:---------------------------------------|:--------------------|:----------------|:-----------------------|:----------------------|:---------------|:------------|:------------|:----------------|
| 61e08ee5b3a1c7a44a6f825f | 06/13/2017 | Demo went really well                  | Yes                 | Meeting         | Tech Demo              |                       | Linda DeCastro | Completed   |             | Johnny Gonzalez |
| 61e08586100f415129d8f8f7 | 06/30/2017 | Updated pipeline status to “Proposal”  | Yes                 |                 |                        | 12/20/2021 4:36pm     | Linda DeCastro | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c8b | 07/02/2017 | Want to be sure to communicate weekly. | Yes                 | Meeting         | Meetup                 | 07/06/2017            | Linda DeCastro | Pending     |             | Johnny Gonzalez |

We can see that the `add_task_or_meeting` column of the last record was
changed successfully.

## Delete Records

We can delete records using the `delete_records` function. We simply
provide the object number and record id we want to delete. Let’s delete
the record above that we just modified.

``` r
# Make a copy of the record
retrieve_records("object_2",
                 "contact",
                 "Linda DeCastro")[3,] ->
  record_3

delete_records("object_2",
               "61c0f751333f060721564c85")
#> [1] "Success: (200) OK"
```

We can retrieve the records again to see that it was successfully
deleted.

``` r
retrieve_records("object_2",
                 "contact",
                 "Linda DeCastro") %>%
  kable()
```

| id                       | date       | notes                                  | add_task_or_meeting | task_or_meeting | tasks_or_meeting_types | task/meeting_due_date | contact        | task_status | task_update | sales_rep       |
|:-------------------------|:-----------|:---------------------------------------|:--------------------|:----------------|:-----------------------|:----------------------|:---------------|:------------|:------------|:----------------|
| 61e08ee5b3a1c7a44a6f825f | 06/13/2017 | Demo went really well                  | Yes                 | Meeting         | Tech Demo              |                       | Linda DeCastro | Completed   |             | Johnny Gonzalez |
| 61e08586100f415129d8f8f7 | 06/30/2017 | Updated pipeline status to “Proposal”  | Yes                 |                 |                        | 12/20/2021 4:36pm     | Linda DeCastro | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c8b | 07/02/2017 | Want to be sure to communicate weekly. | Yes                 | Meeting         | Meetup                 | 07/06/2017            | Linda DeCastro | Pending     |             | Johnny Gonzalez |

You can also delete many records at once using `sapply`. Suppose you had
a vector of record ids you wanted to delete; let’s call it
`duplicated_ids`. You can delete them like so:

``` r
# Not run
sapply(duplicated_ids, function(x){
  delete_records("object_#", x)
})
```

## Create Records

Lastly, you can create new records using the `create_records` function.
You provide the object number and a data frame of new records where the
column names match the field labels in the object. For example, let’s
put back the record that we delete earlier but saved in the data frame
`record_3`.

``` r
kable(record_3[,2:11])
```

|     | date       | notes                                  | add_task_or_meeting | task_or_meeting | tasks_or_meeting_types | task/meeting_due_date | contact        | task_status | task_update | sales_rep       |
|:----|:-----------|:---------------------------------------|:--------------------|:----------------|:-----------------------|:----------------------|:---------------|:------------|:------------|:----------------|
| 3   | 07/02/2017 | Want to be sure to communicate weekly. | Yes                 | Meeting         | Meetup                 | 07/06/2017            | Linda DeCastro | Pending     |             | Johnny Gonzalez |

``` r
create_records("object_2",
               record_3[,2:11])
#> [1] "Success: (200) OK"
```

We can retrieve the records again to see that it was successfully put
back.

``` r
retrieve_records("object_2",
                 "contact",
                 "Linda DeCastro") %>%
  kable()
```

| id                       | date       | notes                                  | add_task_or_meeting | task_or_meeting | tasks_or_meeting_types | task/meeting_due_date | contact        | task_status | task_update | sales_rep       |
|:-------------------------|:-----------|:---------------------------------------|:--------------------|:----------------|:-----------------------|:----------------------|:---------------|:------------|:------------|:----------------|
| 61e09006aebd633c315ea285 | 07/02/2017 | Want to be sure to communicate weekly. | Yes                 | Meeting         | Meetup                 | 07/06/2017 12:00am    | Linda DeCastro | Pending     |             | Johnny Gonzalez |
| 61e08ee5b3a1c7a44a6f825f | 06/13/2017 | Demo went really well                  | Yes                 | Meeting         | Tech Demo              |                       | Linda DeCastro | Completed   |             | Johnny Gonzalez |
| 61e08586100f415129d8f8f7 | 06/30/2017 | Updated pipeline status to “Proposal”  | Yes                 |                 |                        | 12/20/2021 4:36pm     | Linda DeCastro | Pending     |             | Johnny Gonzalez |
| 61c0f751333f060721564c8b | 07/02/2017 | Want to be sure to communicate weekly. | Yes                 | Meeting         | Meetup                 | 07/06/2017            | Linda DeCastro | Pending     |             | Johnny Gonzalez |

Now with a new record id.

### Creating many records at once.

You can use the `create_records` function with an arbitrarily large data
frame of new records, but the more records created, the longer the
function takes to finish.

The `create_records` function calls the Knack API for each new record
and waits for a response before proceeding to the next record. I have
considered updating this function to utilize asynchronous API calls but
in the end decided not to. Asynchronous API calls would allow for the
function to continue uploading records in the background while opening
up the R console for use in the meantime. If you think this would be a
good feature to add, please let me know!

## Conclusion

I hope you enjoy this package and please let me know your suggestions
for how to improve it!

### Acknowledgements

I built this package with guidance from Hadley Wickham’s book [Building
R Packages](https://r-pkgs.org/). The `knackr` package utilizes the
`httr`, `jsonlite`, `dplyr`, `magrittr`, `stringr`, and `utils`
packages.
