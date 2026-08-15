# Get tournament overview

Returns overview copy, defending/past champions, and course blurbs for a
tournament's hub page.

## Usage

``` r
pga_tournament_overview(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

## Value

A named list with `tournament_id`, `format_type`, URL fields, plus
tibbles `overview`, `champions`, and `courses`.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_tournament_overview("R2026027")
} # }
```
