# Get an all-time record table

Get an all-time record table

## Usage

``` r
pga_all_time_records(record_id, tour = "R")
```

## Arguments

- record_id:

  Character. Record ID from
  [`pga_all_time_record_categories()`](https://walrusquant.github.io/pgatouR/reference/pga_all_time_record_categories.md).

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble with one row per record holder. Dynamic columns come from the
API headers.
