# Get player tournament results

Returns a player's tournament-by-tournament results for a season
including round scores, finish position, FedExCup points, and earnings.

## Usage

``` r
pga_player_results(player_id)
```

## Arguments

- player_id:

  Character. Player ID.

## Value

A tibble with one row per tournament.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_player_results("52955")
} # }
```
