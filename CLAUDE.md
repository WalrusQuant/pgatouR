# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Package

`pgatouR` — an R client for the PGA Tour’s GraphQL and REST APIs. Ships
tidy tibbles. Package name in `DESCRIPTION` is `pgatouR`
(case-sensitive). Repo directory is lowercase `pgatour`.

## Common commands

Run from the package root in R (or via `Rscript -e '...'`):

``` r
devtools::document()                                    # regenerate NAMESPACE + man/ from roxygen
devtools::load_all()                                    # iterate without installing
devtools::test()                                        # run the full offline test suite
testthat::test_file("tests/testthat/test-stats.R")      # single test file
devtools::check()                                       # full R CMD check (offline — no network needed)
devtools::install()                                     # install locally
source("data-raw/stat_ids.R")                           # rebuild the bundled stat_ids dataset
Rscript data-raw/fixtures.R                             # recapture test fixtures from the live API
pkgdown::build_site()                                   # build docs site (CI also does this)
```

Tests use testthat 3e (edition 3). The suite is offline-only: every test
mocks `pga_graphql_request` / `pga_rest_request` via
[`testthat::local_mocked_bindings`](https://testthat.r-lib.org/reference/local_mocked_bindings.html)
and reads canned responses from `tests/testthat/fixtures/*.rds`. Re-run
`data-raw/fixtures.R` when the upstream API shape changes.

## Architecture

### Two transports, one cache

`R/utils-api.R` is the single chokepoint for all network I/O:

- `pga_graphql_request(operation_name, variables)` — POSTs to
  `https://orchestrator.pgatour.com/graphql`, loads the query text from
  `inst/graphql/<operation_name>.graphql`, sends the `x-api-key` header,
  throttles at 10 req/sec via `req_throttle`, applies
  `req_timeout(30)` + `req_retry(max_tries = 3)` on 408/429/5xx, and
  returns the `data` field. GraphQL `errors` and HTTP ≥400 both abort
  with `cli_abort`. Non-JSON 200 responses are caught and surfaced via
  `pga_parse_json()`.
- `pga_rest_request(path)` — GETs from
  `https://data-api.pgatour.com/<path>`, same throttling + timeout +
  retry, returns parsed JSON.
- `pga_config_request(path)` — GETs from
  `https://orchestrator-config.pgatour.com/<path>` (default tournaments,
  seasons). Same retry policy.
- Query strings are cached in the `.pga_cache` environment, keyed by
  operation name, so each `.graphql` file is read from disk once per
  session.
- The `x-api-key` is a public key embedded in the PGA Tour frontend. The
  bundled default lives in `.pga_api_key_default`; `pga_api_key()`
  prefers the `PGA_API_KEY` env var so users can swap keys without
  reinstalling if the frontend key rotates.

Every user-facing `pga_*()` function in `R/` is a thin wrapper: call
`pga_graphql_request` / `pga_rest_request`, then shape the result into a
tibble. Add new endpoints by dropping a `.graphql` file in
`inst/graphql/` whose stem matches the `operationName`, then calling
`pga_graphql_request("YourOpName", list(...))`. **Mocking depends on the
call going through these two transports** — anything that bypasses them
will be hard to test.

### Compressed payloads

Several GraphQL operations (any ending in `Compressed`,
e.g. `LeaderboardCompressedV3`, `ScorecardCompressedV3`,
`shotDetailsV4Compressed`, `TeeTimesCompressedV2`,
`CurrentLeadersCompressed`, `oddsToWinCompressed`,
`GenericContentCompressed`) return a `payload` string that is
**base64-encoded gzip JSON**. Pass it through `pga_decompress()` from
`R/utils-decompress.R` before parsing. `pga_decompress`:

- Validates input (must be a non-empty character scalar) and wraps each
  step (base64 → gunzip → JSON parse) in a `tryCatch` that re-throws
  with a clear, named error instead of a cryptic C-level `inflateEnd`
  message.
- Uses `jsonlite::fromJSON(..., simplifyVector = TRUE)`, so
  `parsed$players` etc. come back as a data.frame/matrix, not a
  list-of-lists. Flattening code (see `R/leaderboard.R`) depends on that
  shape. When a top-level field comes back as an empty list
  (e.g. `parsed$holes = list()` when no shot data exists), guards must
  check [`is.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)
  and [`length()`](https://rdrr.io/r/base/length.html) before calling
  [`nrow()`](https://rdrr.io/r/base/nrow.html) — see
  `R/shot_details.R:36–39` for the pattern.

### Shared helpers

`R/utils-parse.R`: - `to_snake_case()` / `clean_names()` — convert API
camelCase to snake_case columns. - `make_unique_snake(x)` — sanitize
free-form labels (with spaces/punctuation) into unique snake_case column
names. Uses [`make.unique()`](https://rdrr.io/r/base/make.unique.html)
so duplicate API headers don’t collide. Use this whenever building
columns from dynamic API header strings (`StatDetails$statHeaders`,
`pga_player_results` header labels, etc.). - `validate_tour_code()` —
`"R"` (PGA), `"S"` (Champions), `"H"` (Korn Ferry), `"Y"` (Americas) are
valid. - `safe_pluck(x, ...)` — nested list access that returns `NULL`
instead of erroring; used heavily when reshaping heterogeneous API
responses.

Row-binding uses
[`vctrs::vec_rbind()`](https://vctrs.r-lib.org/reference/vec_bind.html)
(not `do.call(rbind, ...)`) so heterogeneous columns across chunks get
filled with `NA` instead of erroring. `vec_cbind()` is the equivalent
for column binding.

`%||%` (from base R 4.4+, but the package `Depends: R (>= 4.1.0)`) is
used throughout — if it’s unavailable on the minimum R version, that
will surface as a check failure.

### Bundled data

`data/stat_ids.rda` (built from `data-raw/stat_ids.R`, a ~340-row
`tribble` of stat metadata) is exposed as the `stat_ids` dataset. When
adding/renaming stats, edit `data-raw/stat_ids.R` and re-source it so
`usethis::use_data(overwrite = TRUE)` rewrites the `.rda`.

### Stats vectorization

`pga_stats(stat_id, year, tour, event_query)` accepts **vectors** for
`stat_id` and `year`. The upstream `StatDetails` GraphQL operation only
batches one stat × one year per request, so the function loops
internally and row-binds via `vec_rbind`, prepending `stat_id` and
`year` columns so chunks can be told apart. The single-call worker is
`pga_stats_one()` (not exported). The `event_query` argument passes
through to the upstream `StatDetailEventQuery` variable (used for “Last
5 events” / FedEx Fall filters) and is also exposed on
[`pga_fedex_cup()`](https://walrusquant.github.io/pgatouR/reference/pga_fedex_cup.md).

### Function → file map

Roughly one file per endpoint family (`R/leaderboard.R`,
`R/scorecard.R`, `R/shot_details.R`, `R/stats.R`, `R/schedule.R`,
`R/player_profile.R`, `R/players.R`, `R/tournaments.R`,
`R/tournament_details.R`, `R/field.R`, `R/course_stats.R`,
`R/standings.R`, `R/group_locations.R`, `R/news.R`, `R/videos.R`,
`R/odds.R`, `R/coverage.R`, `R/tee_times.R`, `R/fedex_cup.R`,
`R/scorecard_comparison.R`, `R/current_leaders.R`, `R/content.R`).
Exports are driven by roxygen `@export` tags — edit roxygen, then run
`devtools::document()` to regenerate `NAMESPACE` and `man/`.

### Tests + fixtures

- `tests/testthat/helper-fixtures.R` exposes `read_fixture(name)`,
  `mock_graphql(name)`, `mock_rest(name)`, and
  `mock_graphql_router(routes)` (for tests that need to dispatch
  multiple operations).
- One `test-*.R` file per family; mocks use
  [`testthat::local_mocked_bindings`](https://testthat.r-lib.org/reference/local_mocked_bindings.html)
  to swap in fixture data for the test’s duration.
- `data-raw/fixtures.R` re-captures all fixtures from the live API. Run
  it with network access whenever the upstream API shape changes.

### Reference

`data-raw/pgatour_api_docs.md` is the primary reference for the upstream
API’s shape and available operations — consult it before inventing field
names or adding new endpoints.

## CI / docs

`.github/workflows/pkgdown.yaml` installs the package and builds the
pkgdown site on pushes. `_pkgdown.yml` configures the site (deployed at
`https://walrusquant.github.io/pgatouR/`). `data-raw/`, `vignettes/`,
`.github/`, `.claude/`, and `CLAUDE.md` are excluded from the built
package via `.Rbuildignore`. The upstream API reference
(`data-raw/pgatour_api_docs.md`) lives under `data-raw/` so it’s both
excluded from the build and outside pkgdown’s auto-render scope.

The long-form guide lives at `vignettes/articles/getting-started.Rmd` —
pkgdown picks it up as an “article” on the docs site. It is not a
CRAN-style vignette, so it isn’t tangled or executed by R CMD check (the
previous setup ran live API calls during check, which made the check
fragile).
