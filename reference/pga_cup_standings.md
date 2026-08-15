# Get default tour-cup standings

Simpler cup table than
[`pga_fedex_cup()`](https://walrusquant.github.io/pgatouR/reference/pga_fedex_cup.md):
uses `defaultTourCup`, so the correct cup is selected per tour
(FedExCup, Schwab, Fortinet, Americas points).

## Usage

``` r
pga_cup_standings(year = as.integer(format(Sys.Date(), "%Y")), tour = "R")
```

## Arguments

- year:

  Integer. Season year. Defaults to the current year.

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble of cup ranking rows.
