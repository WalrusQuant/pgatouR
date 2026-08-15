# Get historical results for a tournament

Returns the full field result list for a prior playing of an event.
`tournament_id` is the current-season ID (e.g. `"R2026027"`); `year`
selects which edition.

## Usage

``` r
pga_tournament_past_results(tournament_id, year = NULL)
```

## Arguments

- tournament_id:

  Character. Tournament ID.

- year:

  Integer or `NULL`. Season to return. `NULL` uses the latest available
  season in the response.

## Value

A tibble with one row per player, plus round-score columns.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_tournament_past_results("R2026027", year = 2025)
} # }
```
