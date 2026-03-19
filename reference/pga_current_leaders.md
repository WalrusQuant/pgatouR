# Get current leaders snapshot

Returns a quick leaderboard snapshot for an in-progress tournament. For
the full leaderboard, use
[`pga_leaderboard()`](https://walrusquant.github.io/pgatouR/reference/pga_leaderboard.md).

## Usage

``` r
pga_current_leaders(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026475"`).

## Value

A tibble of current leaders.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_current_leaders("R2026475")
} # }
```
