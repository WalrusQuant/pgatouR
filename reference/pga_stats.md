# Get PGA Tour statistics

Returns player rankings for any of 300+ PGA Tour statistics. See
[stat_ids](https://walrusquant.github.io/pgatouR/reference/stat_ids.md)
for a full list of available stat IDs.

## Usage

``` r
pga_stats(stat_id, year = NULL, tour = "R")
```

## Arguments

- stat_id:

  Character. Stat ID (e.g., `"02675"` for SG: Total).

- year:

  Integer or NULL. Season year. Defaults to current season.

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble with one row per player, including rank, player info, and stat
values.

## Examples

``` r
if (FALSE) { # \dontrun{
# Strokes Gained: Total
pga_stats("02675")

# Driving Distance, 2024 season
pga_stats("101", year = 2024)
} # }
```
