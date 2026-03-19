# Get scorecard stat comparison between players

Returns stat comparison categories for players in a tournament.

## Usage

``` r
pga_scorecard_comparison(tournament_id, player_ids, category = "SCORING")
```

## Arguments

- tournament_id:

  Character. Tournament ID (e.g., `"R2026475"`).

- player_ids:

  Character vector. Player IDs to compare.

- category:

  Character. Comparison category. Common values: `"SCORING"`,
  `"DRIVING"`, `"APPROACH"`, `"SHORT_GAME"`, `"PUTTING"`. Defaults to
  `"SCORING"`.

## Value

A tibble of comparison data with available category pills.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_scorecard_comparison("R2026475", c("39971", "46046"), "SCORING")
} # }
```
