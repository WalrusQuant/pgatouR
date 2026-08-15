# Get the tour's current / featured tournament

Reads the PGA Tour web-config default tournament for a tour — the same
source the live site uses for "this week."

## Usage

``` r
pga_current_tournament(tour = "R")
```

## Arguments

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble with one row per featured event (`tournament_id`,
`leaderboard_id`). Empty when the config has no default for that tour.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_current_tournament()
pga_current_tournament("Y")
} # }
```
