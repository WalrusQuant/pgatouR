# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package

`pgatouR` — an R client for the PGA Tour's GraphQL and REST APIs. Ships tidy tibbles. Package name in `DESCRIPTION` is `pgatouR` (case-sensitive). Repo directory is lowercase `pgatour`.

## Common commands

Run from the package root in R (or via `Rscript -e '...'`):

```r
devtools::document()          # regenerate NAMESPACE + man/ from roxygen
devtools::load_all()          # iterate without installing
devtools::test()              # run all testthat tests
testthat::test_file("tests/testthat/test-utils.R")   # single test file
devtools::check()             # full R CMD check
devtools::install()           # install locally
source("data-raw/stat_ids.R") # rebuild bundled stat_ids dataset
pkgdown::build_site()         # build docs site (CI also does this)
```

Tests use testthat 3e (edition 3). There is currently only `test-utils.R` covering helpers; network-hitting functions are not unit-tested.

## Architecture

### Two transports, one cache

`R/utils-api.R` is the single chokepoint for all network I/O:

- `pga_graphql_request(operation_name, variables)` — POSTs to `https://orchestrator.pgatour.com/graphql`, loads the query text from `inst/graphql/<operation_name>.graphql`, sends the `x-api-key` header (a public key embedded in the PGA Tour frontend), throttles at 10 req/sec via `req_throttle`, and returns the `data` field. GraphQL `errors` and HTTP ≥400 both abort with `cli_abort`.
- `pga_rest_request(path)` — GETs from `https://data-api.pgatour.com/<path>`, same throttling, returns parsed JSON.
- Query strings are cached in the `.pga_cache` environment, keyed by operation name, so each `.graphql` file is read from disk once per session.

Every user-facing `pga_*()` function in `R/` is a thin wrapper: call `pga_graphql_request` / `pga_rest_request`, then shape the result into a tibble. Add new endpoints by dropping a `.graphql` file in `inst/graphql/` whose stem matches the `operationName`, then calling `pga_graphql_request("YourOpName", list(...))`.

### Compressed payloads

Several GraphQL operations (any ending in `Compressed`, e.g. `LeaderboardCompressedV3`, `ScorecardCompressedV3`, `shotDetailsV4Compressed`, `TeeTimesCompressedV2`, `CurrentLeadersCompressed`, `oddsToWinCompressed`) return a `payload` string that is **base64-encoded gzip JSON**. Pass it through `pga_decompress()` from `R/utils-decompress.R` before parsing. `pga_decompress` uses `jsonlite::fromJSON(..., simplifyVector = TRUE)`, so `parsed$players` etc. come back as a data.frame/matrix, not a list-of-lists — flattening code (see `R/leaderboard.R`) depends on that shape.

### Shared helpers

`R/utils-parse.R`:
- `to_snake_case()` / `clean_names()` — convert API camelCase to snake_case columns.
- `validate_tour_code()` — only `"R"` (PGA), `"S"` (Champions), `"H"` (Korn Ferry) are valid.
- `safe_pluck(x, ...)` — nested list access that returns `NULL` instead of erroring; used heavily when reshaping heterogeneous API responses.

`%||%` (from base R 4.4+, but the package `Depends: R (>= 4.1.0)`) is used throughout — if it's unavailable on the minimum R version, that will surface as a check failure.

### Bundled data

`data/stat_ids.rda` (built from `data-raw/stat_ids.R`, a ~340-row `tribble` of stat metadata) is exposed as the `stat_ids` dataset. When adding/renaming stats, edit `data-raw/stat_ids.R` and re-source it so `usethis::use_data(overwrite = TRUE)` rewrites the `.rda`.

### Function → file map

Roughly one file per endpoint family (`R/leaderboard.R`, `R/scorecard.R`, `R/shot_details.R`, `R/stats.R`, `R/schedule.R`, `R/player_profile.R`, `R/players.R`, `R/tournaments.R`, `R/news.R`, `R/videos.R`, `R/odds.R`, `R/coverage.R`, `R/tee_times.R`, `R/fedex_cup.R`, `R/scorecard_comparison.R`, `R/current_leaders.R`). Exports are driven by roxygen `@export` tags — edit roxygen, then run `devtools::document()` to regenerate `NAMESPACE` and `man/`.

### Reference

`pgatour_api_docs.md` at the repo root is the primary reference for the upstream API's shape and available operations — consult it before inventing field names or adding new endpoints.

## CI / docs

`.github/workflows/pkgdown.yaml` installs the package and builds the pkgdown site on pushes. `_pkgdown.yml` configures the site (deployed at `https://walrusquant.github.io/pgatouR/`). `pgatour_api_docs.md`, `data-raw/`, `.github/`, and `.claude/` are excluded from the built package via `.Rbuildignore`.
