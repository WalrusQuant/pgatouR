# Get tee times for a tournament

Returns tee time groupings for each round of a tournament.

## Usage

``` r
pga_tee_times(tournament_id)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026475"`).

## Value

A tibble with one row per player per round, including tee time, starting
tee, and group assignments.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_tee_times("R2026475")
} # }
```
