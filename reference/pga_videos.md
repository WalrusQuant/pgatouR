# Get player video highlights

Returns video content with optional filtering by player, tournament, and
franchise categories.

## Usage

``` r
pga_videos(
  player_ids = NULL,
  tournament_id = NULL,
  tour = "R",
  season = NULL,
  franchises = NULL,
  limit = 18L,
  offset = 0L
)
```

## Arguments

- player_ids:

  Character vector or NULL. Player IDs to filter by.

- tournament_id:

  Character or NULL. Tournament ID (numeric part only, e.g., `"475"`).

- tour:

  Character. Tour code. Defaults to `"R"`.

- season:

  Character or NULL. Season year as string (e.g., `"2026"`).

- franchises:

  Character vector or NULL. Franchise filters (e.g.,
  `"competition#highlights"`).

- limit:

  Integer. Max videos. Defaults to 18.

- offset:

  Integer. Pagination offset. Defaults to 0.

## Value

A tibble of videos.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_videos(player_ids = "39971", tournament_id = "475")
} # }
```
