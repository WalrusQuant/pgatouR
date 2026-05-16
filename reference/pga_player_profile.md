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

A named list with scalar bio fields (`player_id`, `first_name`,
`last_name`, `country`, `country_code`, `born`, `age`, `birthplace`,
`college`, `turned_pro`) plus two tibbles: `highlights` (career
highlight cards) and `overview` (overview-stats grid).

## Examples

``` r
if (FALSE) { # \dontrun{
pga_player_profile("52955")
} # }
```
