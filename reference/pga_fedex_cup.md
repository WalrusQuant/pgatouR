# Get FedExCup standings

Returns FedExCup standings with projected and official rankings.

## Usage

``` r
pga_fedex_cup(year = as.integer(format(Sys.Date(), "%Y")), tour = "R")
```

## Arguments

- year:

  Integer. Season year. Defaults to current year.

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble with player standings including rank, points, and movement.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_fedex_cup(2026)
} # }
```
