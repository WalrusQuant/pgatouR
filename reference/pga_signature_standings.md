# Get signature-event standings

Official and interim signature-event tables (Aon / signature series).

## Usage

``` r
pga_signature_standings(tour = "R")
```

## Arguments

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble with one row per player per table (`table` is `"official"` or
`"interim"`).

## Examples

``` r
if (FALSE) { # \dontrun{
pga_signature_standings()
} # }
```
