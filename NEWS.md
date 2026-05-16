# pgatouR (development version)

## Breaking changes

* `pga_player_tournament_status()` now returns a zero-row tibble when the
  API has no status to report (player not currently in a tournament). It
  previously returned a one-row tibble with all `NA` columns. The column
  schema is unchanged.
* `pga_stats()` no longer attaches metadata (`stat_title`, `tour_avg`,
  `year`, `display_season`) as attributes. `stat_title`, `stat_id`, and
  `year` are now real columns on the returned tibble; the other metadata
  was dropped (it was silently lost the moment any dplyr verb ran on the
  result anyway).

## New features

* `pga_stats()` accepts vectors for `stat_id` and `year`, looping
  internally and stacking results with `stat_id` and `year` columns.
* `pga_stats()` and `pga_fedex_cup()` gain an `event_query` argument that
  passes through to the upstream `StatDetailEventQuery` variable.
* Three new endpoints fill out documented API coverage: `pga_content()`
  (CMS content), `pga_odds_interactivity()` (odds widget config), and
  `pga_speed_rounds()` (speed-rounds video index).
* `PGA_API_KEY` env var overrides the bundled frontend key so users can
  swap keys without reinstalling if the public key rotates.
* `PGATOUR_VERBOSE` env var enables request-level logging via `cli` for
  troubleshooting.

## Bug fixes

* `pga_player_tournament_status()`: fixed phantom `roundDisplay` mapping
  that was always `NA`. The fields actually returned by the API
  (`roundStatusDisplay`, `roundStatusColor`) are now surfaced as columns.
* `pga_player_results()`: was hardcoding the first season in the response,
  silently dropping all other seasons. Now returns every season with a
  `season` column.
* `pga_player_stats()`: `rank` is now an integer column rather than
  character.
* `pga_shot_details()`: no longer crashes with "missing value where
  TRUE/FALSE needed" when the API returns an empty `holes` list (e.g.
  player with no tracked shots that round).
* `pga_decompress()`: malformed payloads (empty string, non-base64,
  invalid gzip, invalid JSON) now produce clear errors naming the failed
  step instead of cryptic C-level messages like `inflateEnd -3`.
* Header-derived column names that previously collided (e.g. two `"Rank"`
  labels in player results, free-form spaces in stat headers) are now
  deduplicated via `make_unique_snake()`.

## Robustness / performance

* Transport now applies a 30-second `req_timeout()` and a three-try
  `req_retry()` on 408/429/5xx, so transient CDN failures recover
  automatically instead of failing the call.
* Non-JSON 200 responses are caught and surfaced with the operation name
  and status code, instead of crashing in `resp_body_json()`.
* `pga_tee_times()` now builds one tibble per group rather than per
  player, drastically reducing allocations on large fields.
* `pga_leaderboard()` now `%||%`-guards every player/scoring field so a
  partial response from the API can't break tibble construction.
  `total_sort` and `score_sort` are returned as numeric (they were
  character).
* `pga_tournaments()` uses `vctrs::vec_rbind()` for the `courses`
  list-column so heterogeneous course schemas no longer silently fall
  back to an empty tibble.

## Testing / infra

* Added an offline test suite (89 tests across 10 files) that mocks
  `pga_graphql_request` / `pga_rest_request` against fixtures captured
  in `tests/testthat/fixtures/`. Re-capture with
  `Rscript data-raw/fixtures.R`.
* Added an `R-CMD-check` GitHub Actions workflow that runs on macOS and
  Ubuntu against R release, devel, and oldrel-1.
* `R/utils-parse.R` defines `%||%` locally so the package works on R
  versions older than 4.4 (which is when `%||%` landed in base).
* The long-form guide moved from a CRAN-style vignette to a pkgdown
  article in `vignettes/articles/`. R CMD check no longer tangles and
  runs its live API calls.

# pgatouR 0.1.0

Initial release.

## Functions

### Live Tournament Data
- `pga_leaderboard()` — Full leaderboard with scores, positions, and round-by-round results
- `pga_current_leaders()` — Quick top-15 snapshot for in-progress tournaments
- `pga_tee_times()` — Tee time groupings with start tees and player assignments
- `pga_scorecard()` — Hole-by-hole scorecard with par, score, yardage, and status
- `pga_shot_details()` — Shot-by-shot tracking data with coordinates and play-by-play
- `pga_odds()` — Betting odds to win for the tournament field
- `pga_coverage()` — Broadcast and streaming schedule

### Statistics & Standings
- `pga_stats()` — Any of 300+ stats with full player rankings (2004-2026)
- `pga_fedex_cup()` — FedExCup standings with projected and official rankings
- `pga_scorecard_comparison()` — Head-to-head stat comparison between players

### Players & Tournaments
- `pga_players()` — Full player directory (2,400+ players across PGA Tour, Champions, Korn Ferry)
- `pga_tournaments()` — Tournament metadata including location, courses, weather, and format
- `pga_schedule()` — Full season schedule with dates, purse, course, champion, and FedExCup points

### Player Profiles
- `pga_player_profile()` — Overview with career highlights, wins, earnings, world rank, bio basics
- `pga_player_career()` — Career achievements: starts, cuts, wins, finish distribution, earnings
- `pga_player_results()` — Tournament-by-tournament results with round scores and earnings
- `pga_player_stats()` — Full stat profile (131 stats with ranks) in a single call
- `pga_player_bio()` — Biographical text and amateur highlights
- `pga_player_tournament_status()` — Live tournament status if currently playing

### Content
- `pga_news()` — News articles with filtering and pagination
- `pga_news_franchises()` — Available news categories
- `pga_videos()` — Player video highlights
- `pga_tourcast_videos()` — Shot-by-shot video clips

### Data
- `stat_ids` — Bundled lookup table of 340 stat IDs with names, categories, and subcategories
