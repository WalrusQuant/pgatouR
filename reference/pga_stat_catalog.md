# Get the live stat catalog

Categories and stat IDs from `StatOverview` — the same tree the stats
hub uses. Useful for refreshing
[stat_ids](https://walrusquant.github.io/pgatouR/reference/stat_ids.md)
or discovering new stats.

## Usage

``` r
pga_stat_catalog(tour = "R", year = NULL)
```

## Arguments

- tour:

  Character. Tour code. Defaults to `"R"`.

- year:

  Integer or `NULL`. Season year.

## Value

A tibble with `stat_id`, `stat_name`, `category`, `subcategory`.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_stat_catalog()
} # }
```
