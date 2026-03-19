# Get broadcast/streaming coverage info

Returns broadcast and streaming schedule for a tournament, including
networks, stream URLs, and time windows.

## Usage

``` r
pga_coverage(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026475"`).

## Value

A tibble of coverage entries.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_coverage("R2026475")
} # }
```
