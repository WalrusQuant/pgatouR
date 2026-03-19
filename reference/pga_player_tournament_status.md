# Get player tournament status

Returns a player's status in the current tournament (if playing),
including position, score, and tee time.

## Usage

``` r
pga_player_tournament_status(player_id)
```

## Arguments

- player_id:

  Character. Player ID.

## Value

A tibble with one row, or empty if the player is not in the current
tournament.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_player_tournament_status("52955")
} # }
```
