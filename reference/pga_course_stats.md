# Get hole-level course stats for a tournament

Scoring averages, birdie/bogey counts, and rank for each hole, by round.

## Usage

``` r
pga_course_stats(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

## Value

A tibble with one row per course-round-hole. Summary rows (front nine /
back nine / total) are included with `is_summary = TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_course_stats("R2026027")
} # }
```
