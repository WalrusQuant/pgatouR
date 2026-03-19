# Get tournament metadata

Returns tournament details including name, location, courses, weather,
status, and format.

## Usage

``` r
pga_tournaments(ids)
```

## Arguments

- ids:

  Character vector. One or more tournament IDs (e.g., `"R2026475"`).

## Value

A tibble with one row per tournament.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_tournaments("R2026475")
pga_tournaments(c("R2026475", "R2026003"))
} # }
```
