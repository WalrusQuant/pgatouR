# Get betting markets for one player

Per-player finish / prop / matchup lines from
`/odds/tournament/{id}/player/{id}`.

## Usage

``` r
pga_odds_player(tournament_id, player_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

- player_id:

  Character. Player ID.

## Value

A tibble with one row per quoted line.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_odds_player("R2026027", "46046")
} # }
```
