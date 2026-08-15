# Get live group locations on the course

Where each grouping is on the course for a given round.

## Usage

``` r
pga_group_locations(tournament_id, round)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

- round:

  Integer. Round number.

## Value

A tibble with one row per group-on-hole.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_group_locations("R2026027", round = 3)
} # }
```
