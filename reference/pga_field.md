# Get the tournament field

Returns players (and optionally alternates) entered in a tournament,
including OWGR, withdrawn/alternate flags, and qualifier status.

## Usage

``` r
pga_field(tournament_id, include_withdrawn = TRUE)
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026027"`).

- include_withdrawn:

  Logical. Include withdrawn players. Defaults to `TRUE`.

## Value

A tibble with one row per player. Alternates are included with
`role = "alternate"`.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_field("R2026027")
} # }
```
