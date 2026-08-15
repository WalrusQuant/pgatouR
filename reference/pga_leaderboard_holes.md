# Get hole-by-hole scores for the field

Returns one row per player per hole for a tournament round.

## Usage

``` r
pga_leaderboard_holes(tournament_id, round = NULL)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026027"`).

- round:

  Integer or `NULL`. Round number. `NULL` (default) uses the
  current/latest round returned by the API.

## Value

A tibble with one row per player-hole.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_leaderboard_holes("R2026027", round = 2)
} # }
```
