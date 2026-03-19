# Get shot-level tracking data

Returns shot-by-shot data with coordinates for a player's round,
including distance, stroke type, play-by-play descriptions, and
coordinate data for shot visualization.

## Usage

``` r
pga_shot_details(tournament_id, player_id, round, include_radar = FALSE)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026475"`).

- player_id:

  Character. Player ID (e.g., `"39971"`).

- round:

  Integer. Round number (1-4).

- include_radar:

  Logical. Include radar data. Defaults to `FALSE`.

## Value

A tibble with one row per stroke, including hole-level context.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_shot_details("R2026475", "39971", round = 1)
} # }
```
