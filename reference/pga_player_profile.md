# Get player profile overview

Returns a player's profile summary including career highlights, wins,
earnings, world ranking, FedExCup standing, and bio basics.

## Usage

``` r
pga_player_profile(player_id)
```

## Arguments

- player_id:

  Character. Player ID (e.g., `"52955"` for Ludvig Aberg).

## Value

A named list with `summary` (tibble of career highlights) and `bio`
(list of biographical info).

## Examples

``` r
if (FALSE) { # \dontrun{
pga_player_profile("52955")
} # }
```
