# Get field form / course-fit stats

Wraps `FieldStats`. `stat_type` is an upstream `FieldStatType` value:
`"COURSE_FIT"` or `"CURRENT_FORM"`.

## Usage

``` r
pga_field_stats(tournament_id, stat_type = "COURSE_FIT")
```

## Arguments

- tournament_id:

  Character. Tournament ID.

- stat_type:

  Character. `"COURSE_FIT"` (default) or `"CURRENT_FORM"`.

## Value

A tibble with one row per player. Extra nested blocks (recent results,
strokes-gained) are list-columns when present.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_field_stats("R2026027")
pga_field_stats("R2026027", "CURRENT_FORM")
} # }
```
