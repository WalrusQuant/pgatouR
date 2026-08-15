# Get the season course-stats hub

Category cards from `/stats/course` (hardest/easiest holes, etc.).

## Usage

``` r
pga_course_stats_overview(tour = "R", year = NULL)
```

## Arguments

- tour:

  Character. Tour code. Defaults to `"R"`.

- year:

  Integer or `NULL`. Season year. `NULL` uses the current season.

## Value

A tibble with one row per ranked item.
