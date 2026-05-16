# Get FedExCup standings

Returns FedExCup standings with projected and official rankings.

## Usage

``` r
pga_fedex_cup(
  year = as.integer(format(Sys.Date(), "%Y")),
  tour = "R",
  event_query = NULL
)
```

## Arguments

- year:

  Integer. Season year. Defaults to current year.

- tour:

  Character. Tour code. Defaults to `"R"`.

- event_query:

  Optional named list passed through as the GraphQL
  `StatDetailEventQuery` variable (used for event/window filters). Most
  callers can leave this `NULL`.

## Value

A tibble with player standings including rank, points, and movement.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_fedex_cup(2026)
} # }
```
