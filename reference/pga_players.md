# Get PGA Tour player directory

Returns the full player directory for a tour.

## Usage

``` r
pga_players(tour = "R")
```

## Arguments

- tour:

  Character. Tour code: `"R"` (PGA Tour), `"S"` (Champions), `"H"` (Korn
  Ferry). Defaults to `"R"`.

## Value

A tibble with one row per player.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_players()
pga_players("H")
} # }
```
