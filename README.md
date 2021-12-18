
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

## Example

This is a basic example which shows you how to retrieve data from knack
database. The API ID and API Key shown are for demonstration purposes
only and not active.

``` r
library(knackr)
data <- retrieve_data("object_2",
              api_id = "61be439ed60d72001e68d749",
              api_key = "66f9d76a-093b-4b80-966e-efbd03d0ce6c")

knitr::kable(head(data))
```

| id                       | field_6    | field_7 | field_8   | field_9 | field_10 | field_11 | field_12 |
|:-------------------------|:-----------|:--------|:----------|--------:|---------:|---------:|---------:|
| 61be44b0b1dd4f0721ff4d0c | Volvo      | XC90    | SUV       |      48 |       74 |       14 |       28 |
| 61be44b0b1dd4f0721ff4d0a | Volvo      | S60     | Sedan     |      36 |       65 |       17 |       39 |
| 61be44b0b1dd4f0721ff4d08 | Volkswagon | Tiguan  | SUV       |      25 |       39 |       16 |       35 |
| 61be44b0b1dd4f0721ff4d06 | Volkswagon | Passat  | Sedan     |      23 |       31 |       19 |       39 |
| 61be44b0b1dd4f0721ff4d04 | Volkswagon | Jetta   | Sedan     |      19 |       28 |       21 |       54 |
| 61be44b0b1dd4f0721ff4d02 | Volkswagon | Golf    | Hatchback |      23 |       37 |       19 |       38 |
