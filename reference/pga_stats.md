# Get PGA Tour statistics

Returns player rankings for any of 300+ PGA Tour statistics. See
[stat_ids](https://walrusquant.github.io/pgatouR/reference/stat_ids.md)
for a full list of available stat IDs.

## Usage

``` r
pga_stats(stat_id, year = NULL, tour = "R", event_query = NULL)
```

## Arguments

- stat_id:

  Character vector. One or more stat IDs (e.g., `"02675"` for SG:
  Total). When length \> 1, results are stacked with a `stat_id` column.

- year:

  Integer vector or `NULL`. One or more season years. `NULL` (default)
  uses the current season. When length \> 1, results are stacked with a
  `year` column.

- tour:

  Character. Tour code (`"R"`, `"S"`, `"H"`, or `"Y"`). Defaults to
  `"R"`.

- event_query:

  Optional named list passed through as the GraphQL
  `StatDetailEventQuery` variable (e.g., for "Last 5 events" or FedEx
  Fall filters). Most callers can leave this `NULL`.

## Value

A tibble with one row per player per (stat_id, year) request. Includes
rank, player info, and stat value columns. Multi-stat results are
stacked vertically; columns absent for a given stat are filled with
`NA`.

## Details

The upstream `StatDetails` operation accepts a single `statId` and a
single `year` per request. When `stat_id` or `year` are passed as
vectors, this function loops internally and row-binds the results,
adding `stat_id` and `year` columns so chunks can be told apart.

## Examples

``` r
if (FALSE) { # \dontrun{
# Strokes Gained: Total, current season
pga_stats("02675")

# Driving Distance, 2024 season
pga_stats("101", year = 2024)

# Multiple stats in one call
pga_stats(c("02675", "101"))

# Multi-year SG: Total
pga_stats("02675", year = 2022:2024)
} # }
```
