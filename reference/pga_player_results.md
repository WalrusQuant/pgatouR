# Get player tournament results

Returns a player's tournament-by-tournament results, including round
scores, finish position, FedExCup points, and earnings. If the upstream
response contains multiple seasons, all are returned and tagged with a
`season` column.

## Usage

``` r
pga_player_results(player_id)
```

## Arguments

- player_id:

  Character. Player ID.

## Value

A tibble with one row per tournament. Includes a `season` column (the
season label or index from the API response).

## Examples

``` r
if (FALSE) { # \dontrun{
pga_player_results("52955")
} # }
```
