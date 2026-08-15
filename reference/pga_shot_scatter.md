# Get hole-level shot scatter

Decompresses `ScatterDataCompressed` — the shot cloud for a single hole
(landing spots, lie, etc.). Column names follow the upstream payload
(snake_cased).

## Usage

``` r
pga_shot_scatter(tournament_id, course, hole)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

- course:

  Integer or character. Course ID.

- hole:

  Integer. Hole number.

## Value

A tibble of shot-scatter points.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_shot_scatter("R2026027", course = 513, hole = 1)
} # }
```
