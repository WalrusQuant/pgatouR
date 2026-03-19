# Get odds to win for a tournament

Returns betting odds for each player in the tournament field.

## Usage

``` r
pga_odds(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026475"`).

## Value

A tibble with player odds data.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_odds("R2026475")
} # }
```
