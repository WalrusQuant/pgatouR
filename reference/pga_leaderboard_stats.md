# Get in-tournament stat table

Wraps `LeaderboardStats`. `stats_type` is an upstream
`LeaderboardStatsType` value (e.g. `"OFF_THE_TEE"`, `"APPROACH"`,
`"AROUND_THE_GREEN"`, `"PUTTING"`, `"SCORING"`).

## Usage

``` r
pga_leaderboard_stats(tournament_id, stats_type = NULL)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

- stats_type:

  Character or `NULL`. Stat group. `NULL` uses the API default.

## Value

A tibble with one row per player-stat (overall, plus per-round when the
API returns round splits).
