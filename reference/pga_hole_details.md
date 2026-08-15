# Get details for a single hole

Scoring breakdown plus groups currently on the hole.

## Usage

``` r
pga_hole_details(tournament_id, course_id, hole)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

- course_id:

  Character. Course ID (from
  [`pga_tournaments()`](https://walrusquant.github.io/pgatouR/reference/pga_tournaments.md)
  or
  [`pga_course_stats()`](https://walrusquant.github.io/pgatouR/reference/pga_course_stats.md)).

- hole:

  Integer. Hole number (1-18).

## Value

A named list with hole metadata, `stats` (a one-row tibble), and
`groups` (players on the hole by round).
