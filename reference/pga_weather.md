# Get tournament weather forecast

Hourly and daily forecasts for a tournament site.

## Usage

``` r
pga_weather(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

## Value

A tibble with one row per forecast period (`scope` is `"hourly"` or
`"daily"`).

## Examples

``` r
if (FALSE) { # \dontrun{
pga_weather("R2026027")
} # }
```
