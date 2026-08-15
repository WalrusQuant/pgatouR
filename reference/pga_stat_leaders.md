# Get featured stat leaders

Top of the leaderboard for the stats hub's featured stats (from
`StatOverview$stats`).

## Usage

``` r
pga_stat_leaders(tour = "R", year = NULL)
```

## Arguments

- tour:

  Character. Tour code. Defaults to `"R"`.

- year:

  Integer or `NULL`. Season year.

## Value

A tibble with one row per player per featured stat.
