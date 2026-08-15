# Get priority / exemption rankings

The player-directory priority ranking categories (winners of majors,
career earnings, etc.).

## Usage

``` r
pga_priority_rankings(tour = "R", year = NULL)
```

## Arguments

- tour:

  Character. Tour code. Defaults to `"R"`.

- year:

  Integer or `NULL`. Season year.

## Value

A tibble with one row per category-player.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_priority_rankings()
} # }
```
