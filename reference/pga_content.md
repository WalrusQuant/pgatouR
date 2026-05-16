# Get CMS content fragment

Wraps the `GenericContentCompressed` GraphQL operation. The response is
a decompressed JSON document whose shape varies by `path` — typically
CMS content blocks for editorial pages (overviews, hub pages, sponsor
copy). Returned as a nested list, not a tibble, because the schema isn't
stable.

## Usage

``` r
pga_content(path)
```

## Arguments

- path:

  Character. CMS content path, e.g.
  `"/content/dam/pga-tour/fragments/pages/fedexcup/fedexcup-overview"`.

## Value

The decompressed JSON payload as a nested R list.

## Examples

``` r
if (FALSE) { # \dontrun{
pga_content("/content/dam/pga-tour/fragments/pages/fedexcup/fedexcup-overview")
} # }
```
