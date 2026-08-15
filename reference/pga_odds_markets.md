# Get available betting markets for a tournament

REST catalog of FanDuel (or current book) markets: outright, matchups,
finishes, groups, player props, 3-ball, nationality.

## Usage

``` r
pga_odds_markets(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

## Value

A tibble with one row per market.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_odds_markets("R2026027")
} # }
```
