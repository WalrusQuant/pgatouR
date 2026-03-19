# Get shot-by-shot video clips for a player round

Returns video clips for individual shots in a player's round.

## Usage

``` r
pga_tourcast_videos(tournament_id, player_id, round, hole = NULL, shot = NULL)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026475"`).

- player_id:

  Character. Player ID.

- round:

  Integer. Round number.

- hole:

  Integer or NULL. Specific hole number.

- shot:

  Integer or NULL. Specific shot number.

## Value

A tibble of video clips.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_tourcast_videos("R2026475", "39971", round = 1)
} # }
```
