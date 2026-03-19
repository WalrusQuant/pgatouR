# Get hole-by-hole scorecard

Returns a detailed scorecard for a player in a specific tournament.

## Usage

``` r
pga_scorecard(tournament_id, player_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026475"`).

- player_id:

  Character. Player ID (e.g., `"39971"`).

## Value

A tibble with one row per hole per round, including hole number, par,
score, yardage, status, and round-level metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_scorecard("R2026475", "39971")
} # }
```
