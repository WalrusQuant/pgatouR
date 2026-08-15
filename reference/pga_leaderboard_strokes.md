# Get strokes-gained leaderboard

Decompresses `LeaderboardStrokesCompressed` into a tibble of player
strokes-gained values for the tournament.

## Usage

``` r
pga_leaderboard_strokes(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026027"`).

## Value

A tibble of player strokes-gained rows. Column names follow the upstream
payload (snake_cased).

## Examples

``` r
if (FALSE) { # \dontrun{
pga_leaderboard_strokes("R2026027")
} # }
```
