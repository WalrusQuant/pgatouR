# Get player stats profile

Returns a player's full statistical profile with ranks and values for
130+ stats in a single call. Much more efficient than pulling individual
stats with
[`pga_stats()`](https://walrusquant.github.io/pgatouR/reference/pga_stats.md).

## Usage

``` r
pga_player_stats(player_id)
```

## Arguments

- player_id:

  Character. Player ID.

## Value

A tibble with one row per stat including stat_id, title, rank, value,
category, and supporting stats.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_player_stats("52955")
} # }
```
