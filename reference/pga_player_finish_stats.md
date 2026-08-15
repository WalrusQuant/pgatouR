# Get a player's recent values for one stat

Event-by-event series for a single stat (e.g. SG: Total across the last
ten starts).

## Usage

``` r
pga_player_finish_stats(player_id, stat_id, tour = "R")
```

## Arguments

- player_id:

  Character. Player ID.

- stat_id:

  Character. Stat ID (see
  [stat_ids](https://walrusquant.github.io/pgatouR/reference/stat_ids.md)).

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble with one row per event, plus player-level metadata columns
(`rank`, `player_avg`, `tour_avg`).

## Examples

``` r
if (FALSE) { # \dontrun{
pga_player_finish_stats("46046", "02675")
} # }
```
