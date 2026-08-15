# Get compressed scorecard stats

Strokes-gained and scoring splits shown next to a player's scorecard.

## Usage

``` r
pga_scorecard_stats(tournament_id, player_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

- player_id:

  Character. Player ID.

## Value

A tibble of scorecard stats. Column names follow the upstream payload
(snake_cased).

## Examples

``` r
if (FALSE) { # \dontrun{
pga_scorecard_stats("R2026027", "46046")
} # }
```
