# Get news franchise/category list

Returns available news categories for filtering with
[`pga_news()`](https://walrusquant.github.io/pgatouR/reference/pga_news.md).

## Usage

``` r
pga_news_franchises(tour = "R")
```

## Arguments

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble with franchise and label columns.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_news_franchises()
} # }
```
