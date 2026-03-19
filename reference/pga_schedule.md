# Get season schedule

Returns the full tournament schedule for a season including dates,
status, purse, course, champion, and FedExCup points.

## Usage

``` r
pga_schedule(year = as.integer(format(Sys.Date(), "%Y")), tour = "R")
```

## Arguments

- year:

  Integer. Season year. Defaults to current year.

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble with one row per tournament.

## Examples

``` r
if (FALSE) { # \dontrun{
# Current season
pga_schedule(2026)

# Past season
pga_schedule(2025)
} # }
```
