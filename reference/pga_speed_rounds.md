# Get speed-rounds video index

Returns a list of speed-round videos for a given tour. Useful as a
content discovery surface; returned as a nested list because the entry
shapes are heterogeneous.

## Usage

``` r
pga_speed_rounds(tour = "R")
```

## Arguments

- tour:

  Character. Tour code (`"R"`, `"S"`, or `"H"`). Defaults to `"R"`.

## Value

The parsed JSON response as a nested R list.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_speed_rounds()
} # }
```
