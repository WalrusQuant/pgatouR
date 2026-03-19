# Get tournament leaderboard

Returns the full leaderboard for a tournament with player scores,
positions, and round-by-round results.

## Usage

``` r
pga_leaderboard(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026475"`).

## Value

A tibble with one row per player.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_leaderboard("R2026475")
} # }
```
