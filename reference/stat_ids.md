# PGA Tour Stat ID Lookup Table

A tibble containing all known PGA Tour stat IDs, names, and categories.
Use with
[`pga_stats()`](https://walrusquant.github.io/pgatouR/reference/pga_stats.md)
to look up valid stat IDs.

## Usage

``` r
stat_ids
```

## Format

A tibble with 4 columns:

- stat_id:

  Character. The stat ID to pass to
  [`pga_stats()`](https://walrusquant.github.io/pgatouR/reference/pga_stats.md).

- stat_name:

  Character. Human-readable stat name.

- category:

  Character. Top-level category (e.g., "Strokes Gained", "Putting").

- subcategory:

  Character. Subcategory (e.g., "Driving Leaders", "Putts per Round").

## Examples

``` r
# Browse all strokes gained stats
stat_ids[stat_ids$category == "Strokes Gained", ]
#> # A tibble: 6 × 4
#>   stat_id stat_name              category       subcategory           
#>   <chr>   <chr>                  <chr>          <chr>                 
#> 1 02675   SG: Total              Strokes Gained Strokes Gained Leaders
#> 2 02674   SG: Tee-to-Green       Strokes Gained Strokes Gained Leaders
#> 3 02567   SG: Off-the-Tee        Strokes Gained Strokes Gained Leaders
#> 4 02568   SG: Approach the Green Strokes Gained Strokes Gained Leaders
#> 5 02569   SG: Around-the-Green   Strokes Gained Strokes Gained Leaders
#> 6 02564   SG: Putting            Strokes Gained Strokes Gained Leaders

# Find a stat by name
stat_ids[grep("Driving Distance", stat_ids$stat_name), ]
#> # A tibble: 2 × 4
#>   stat_id stat_name                     category    subcategory          
#>   <chr>   <chr>                         <chr>       <chr>                
#> 1 101     Driving Distance              Off The Tee Driving Distance     
#> 2 317     Driving Distance - All Drives Off The Tee Distance (All Drives)
```
