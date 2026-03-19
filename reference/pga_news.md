# Get news articles

Returns PGA Tour news articles with optional filtering.

## Usage

``` r
pga_news(
  tour = "R",
  franchises = NULL,
  player_ids = NULL,
  limit = 20L,
  offset = 0L
)
```

## Arguments

- tour:

  Character. Tour code. Defaults to `"R"`.

- franchises:

  Character vector or NULL. Filter by franchise categories.

- player_ids:

  Character vector or NULL. Filter by player IDs.

- limit:

  Integer. Maximum number of articles. Defaults to 20.

- offset:

  Integer. Pagination offset. Defaults to 0.

## Value

A tibble with one row per article.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_news()
pga_news(limit = 5)
} # }
```
