# Get player bio

Returns a player's biographical text, amateur highlights, and any
available widget data (physical stats, exempt status, location,
personal).

## Usage

``` r
pga_player_bio(player_id)
```

## Arguments

- player_id:

  Character. Player ID.

## Value

A named list with `text` (character vector of bio paragraphs),
`amateur_highlights` (character vector), and `widgets` (tibble).

## Examples

``` r
if (FALSE) { # \dontrun{
pga_player_bio("52955")
} # }
```
