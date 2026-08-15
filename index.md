# pgatouR ![](reference/figures/logo.png)

An R client for the PGA Tour API. Access leaderboards, fields, course
stats, player stats, scorecards, shot tracking, tee times, FedExCup and
signature standings, betting markets, broadcast schedules, news, and
video highlights — all returned as tidy tibbles.

## Installation

``` r
# Install from GitHub
devtools::install_github("WalrusQuant/pgatouR")
```

## Quick Start

``` r
library(pgatouR)

# This week's featured event, then its leaderboard
tid <- pga_current_tournament()$tournament_id
pga_leaderboard(tid)

# Strokes Gained: Total rankings
pga_stats("02675")

# Multiple stats or multiple years in a single call
pga_stats(c("02675", "101"), year = 2023:2024)

# Full player directory (2,700+ players)
pga_players()

# Hole-by-hole scorecard
pga_scorecard(tid, "46046")

# Shot-level tracking with coordinates
pga_shot_details(tid, "46046", round = 1)

# Full season schedule with dates, purse, champions
pga_schedule(2025)
```

## Functions

### Live Tournament Data

| Function                                            | Description                                                                              |
|-----------------------------------------------------|------------------------------------------------------------------------------------------|
| `pga_current_tournament(tour)`                      | Featured / this-week tournament ID for a tour                                            |
| `pga_leaderboard(tournament_id)`                    | Full leaderboard with scores, positions, movement, tee times, and round-by-round results |
| `pga_current_leaders(tournament_id)`                | Quick top-15 snapshot for in-progress tournaments                                        |
| `pga_leaderboard_holes(tournament_id, round)`       | Hole-by-hole scores for the entire field                                                 |
| `pga_leaderboard_strokes(tournament_id)`            | Strokes-gained leaderboard                                                               |
| `pga_leaderboard_stats(tournament_id, stats_type)`  | In-tournament stat table (off-the-tee, approach, putting, …)                             |
| `pga_field(tournament_id)`                          | Tournament field with OWGR, withdrawn/alternate flags                                    |
| `pga_field_stats(tournament_id, stat_type)`         | Course-fit or current-form stats for the field                                           |
| `pga_tee_times(tournament_id)`                      | Tee time groupings with start tees and player assignments                                |
| `pga_scorecard(tournament_id, player_id)`           | Hole-by-hole scorecard with par, score, yardage, and status                              |
| `pga_scorecard_stats(tournament_id, player_id)`     | Scorecard-adjacent strokes-gained / scoring splits                                       |
| `pga_shot_details(tournament_id, player_id, round)` | Shot-by-shot tracking data with coordinates, distances, and play-by-play                 |
| `pga_shot_scatter(tournament_id, course, hole)`     | Hole-level shot cloud                                                                    |
| `pga_group_locations(tournament_id, round)`         | Live group locations on the course                                                       |
| `pga_odds(tournament_id)`                           | Betting odds to win for the tournament field                                             |
| `pga_odds_markets(tournament_id)`                   | Available betting markets (matchups, finishes, props, 3-ball)                            |
| `pga_odds_player(tournament_id, player_id)`         | Per-player betting lines                                                                 |
| `pga_coverage(tournament_id)`                       | Broadcast and streaming schedule with networks and time windows                          |
| `pga_weather(tournament_id)`                        | Hourly and daily forecast for the tournament site                                        |

### Statistics & Standings

| Function                                                        | Description                                                                                                                    |
|-----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| `pga_stats(stat_id, year, tour, event_query)`                   | Any of 470+ stats with full player rankings (data from 2004–2026). Accepts vectors of `stat_id` / `year` for batched requests. |
| `pga_stat_catalog(tour, year)`                                  | Live stat catalog (id, name, category) from the stats hub                                                                      |
| `pga_stat_leaders(tour, year)`                                  | Featured stat leaders from the stats hub                                                                                       |
| `pga_fedex_cup(year, tour, event_query)`                        | FedExCup standings with projected and official rankings                                                                        |
| `pga_cup_standings(year, tour)`                                 | Default tour-cup table (FedExCup / Schwab / Fortinet / Americas)                                                               |
| `pga_signature_standings(tour)`                                 | Signature-event standings                                                                                                      |
| `pga_priority_rankings(tour, year)`                             | Priority / exemption ranking categories                                                                                        |
| `pga_bubble(tournament_id, tour)`                               | Playoff / tour-card bubble around the cutoff                                                                                   |
| `pga_all_time_record_categories(tour)`                          | Catalog of all-time record IDs                                                                                                 |
| `pga_all_time_records(record_id, tour)`                         | One all-time record table                                                                                                      |
| `pga_university_rankings(year, week)`                           | PGA TOUR University rankings                                                                                                   |
| `pga_scorecard_comparison(tournament_id, player_ids, category)` | Head-to-head stat comparison between players                                                                                   |

### Players & Tournaments

| Function                                           | Description                                                                   |
|----------------------------------------------------|-------------------------------------------------------------------------------|
| `pga_players(tour)`                                | Full player directory with name, country, age, and active status              |
| `pga_tournaments(ids)`                             | Tournament metadata including location, courses, weather, and format          |
| `pga_tournament_overview(id)`                      | Hub-page overview, champions, and course blurbs                               |
| `pga_tournament_past_results(id, year)`            | Historical field results for an event                                         |
| `pga_schedule(year, tour)`                         | Full season schedule with dates, purse, course, champion, and FedExCup points |
| `pga_course_stats(tournament_id)`                  | Hole-level scoring averages and birdie/bogey counts                           |
| `pga_course_stats_overview(tour, year)`            | Season course-stats hub (hardest/easiest holes, …)                            |
| `pga_hole_details(tournament_id, course_id, hole)` | Scoring breakdown and groups on a single hole                                 |

### Player Profiles

| Function                                      | Description                                                                   |
|-----------------------------------------------|-------------------------------------------------------------------------------|
| `pga_player_profile(player_id)`               | Overview with career highlights, wins, earnings, world rank, bio basics       |
| `pga_player_career(player_id)`                | Career achievements: starts, cuts, wins, finish distribution, earnings        |
| `pga_player_results(player_id)`               | Tournament-by-tournament results with round scores, FedExCup points, earnings |
| `pga_player_stats(player_id)`                 | Full stat profile (131 stats with ranks) in a single call                     |
| `pga_player_finish_stats(player_id, stat_id)` | One stat across a player’s recent events                                      |
| `pga_player_bio(player_id)`                   | Biographical text, amateur highlights                                         |
| `pga_player_tournament_status(player_id)`     | Live tournament status (position, score, thru) if currently playing           |

### Content

| Function                                                                                                | Description                                                              |
|---------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `pga_news(tour, limit, offset)`                                                                         | News articles with filtering by franchise, player, and pagination        |
| `pga_news_franchises(tour)`                                                                             | Available news categories for filtering                                  |
| `pga_videos(player_ids, tournament_id)`                                                                 | Player video highlights with filtering options                           |
| `pga_tourcast_videos(tournament_id, player_id, round)`                                                  | Shot-by-shot video clips for a player’s round                            |
| `pga_speed_rounds(tour)`                                                                                | Speed-rounds video index                                                 |
| `pga_content(path)`                                                                                     | CMS content fragments (overview pages, hub copy) — returns a nested list |
| [`pga_odds_interactivity()`](https://walrusquant.github.io/pgatouR/reference/pga_odds_interactivity.md) | Odds widget / book-partner configuration — returns a nested list         |

### Bundled Data

| Dataset    | Description                                                             |
|------------|-------------------------------------------------------------------------|
| `stat_ids` | Lookup table of 470+ stat IDs with names, categories, and subcategories |

## Tour Codes

| Code  | Tour               |
|-------|--------------------|
| `"R"` | PGA Tour           |
| `"S"` | PGA Tour Champions |
| `"H"` | Korn Ferry Tour    |
| `"Y"` | PGA Tour Americas  |

## Tournament IDs

Tournament IDs follow the format `{tour_code}{year}{tournament_number}`,
e.g. `"R2026027"` for the 2026 FedEx St. Jude Championship.

You can find tournament IDs from
[`pga_current_tournament()`](https://walrusquant.github.io/pgatouR/reference/pga_current_tournament.md)
(this week),
[`pga_schedule()`](https://walrusquant.github.io/pgatouR/reference/pga_schedule.md),
PGA Tour URLs, or
[`pga_tournaments()`](https://walrusquant.github.io/pgatouR/reference/pga_tournaments.md)
once you have an ID.

## Detailed Examples

### Player Profiles

``` r
library(pgatouR)

# Full profile overview
profile <- pga_player_profile("52955")  # Ludvig Aberg
profile$first_name  # "Ludvig"
profile$highlights  # tibble: PGA TOUR Wins, FedExCup rank, World Rank
profile$overview    # tibble: career/season/bio/stats summary

# 131 stats in one call (way faster than pulling individually)
stats <- pga_player_stats("52955")
stats[stats$stat_id == "02675", ]  # SG: Total — rank 13, value 1.245

# Tournament results this season
results <- pga_player_results("52955")
results[, c("tournament", "pos", "total", "to_par", "winnings")]

# Career achievements
pga_player_career("52955")

# Bio and amateur highlights
bio <- pga_player_bio("52955")
bio$text  # paragraphs of biographical text

# Is a player in the current tournament?
pga_player_tournament_status("39971")  # Sungjae Im — position, score, thru

# One stat across recent starts
pga_player_finish_stats("52955", "02675")
```

### Strokes Gained Analysis

``` r
library(pgatouR)

# Pull every strokes-gained category in a single batched call
sg <- pga_stats(c("02675", "02567", "02568", "02569", "02564"))
table(sg$stat_title)
#> SG: Approach   SG: Around-the-Green   SG: Off-the-Tee   SG: Putting   SG: Total
#>          166                    166                166           166         166

# Multi-year version — adds `year` as a column on every row
sg_multi <- pga_stats("02675", year = 2022:2024)
```

### Finding Stats

``` r
# Browse the bundled stat_ids dataset
stat_ids[stat_ids$category == "Putting", ]

# Search by name
stat_ids[grep("Driving", stat_ids$stat_name), ]

# All strokes gained stats
stat_ids[stat_ids$category == "Strokes Gained", ]

# Or pull the live hub catalog (picks up newly published stats)
pga_stat_catalog()
pga_stat_leaders()
```

### Historical Data

``` r
# Driving distance across an arbitrary year range — one call, one tibble
dd <- pga_stats("101", year = 2015:2024)

# FedExCup standings from past seasons
pga_fedex_cup(2025)
pga_fedex_cup(2024)

# Simpler cup table — auto-selects FedEx / Schwab / Fortinet / Americas
pga_cup_standings(2026)
pga_cup_standings(2026, tour = "Y")

# Historical field for an event (59 seasons available for some tournaments)
pga_tournament_past_results("R2026027", year = 2025)

# Full season schedule with dates, purse, course, champion
schedule_2025 <- pga_schedule(2025)
schedule_2026 <- pga_schedule(2026)  # 49 events, future events included
```

### Live Tournament Tracking

``` r
# This week's event (or pass a known ID like "R2026027")
tid <- pga_current_tournament()$tournament_id

tournament  <- pga_tournaments(tid)
leaderboard <- pga_leaderboard(tid)
field       <- pga_field(tid)
holes       <- pga_leaderboard_holes(tid, round = 2)
course      <- pga_course_stats(tid)
weather     <- pga_weather(tid)
tee_times   <- pga_tee_times(tid)
coverage    <- pga_coverage(tid)
odds        <- pga_odds(tid)
markets     <- pga_odds_markets(tid)

# Deep dive on a player
player_id <- "46046"  # Scottie Scheffler
scorecard  <- pga_scorecard(tid, player_id)
sc_stats   <- pga_scorecard_stats(tid, player_id)
shots      <- pga_shot_details(tid, player_id, round = 1)
videos     <- pga_tourcast_videos(tid, player_id, round = 1)
lines      <- pga_odds_player(tid, player_id)
```

### Player Research

``` r
# Get all PGA Tour players (2,700+)
players <- pga_players("R")

# Filter to active players
active <- players[players$is_active, ]

# Korn Ferry Tour / PGA Tour Americas
kft_players <- pga_players("H")
americas    <- pga_players("Y")
```

### News & Video Content

``` r
# Latest news
news <- pga_news(limit = 10)

# News by category
categories <- pga_news_franchises()
power_rankings <- pga_news(franchises = "power-rankings", limit = 5)

# Player highlights
videos <- pga_videos(player_ids = "46046", tournament_id = "475")
```

## Stat Categories

The `stat_ids` dataset covers 470+ stats across these categories:

- **Strokes Gained** — Total, Tee-to-Green, Off-the-Tee, Approach,
  Around-the-Green, Putting
- **Off The Tee** — Driving distance, accuracy, ball speed, club head
  speed, launch angle, spin rate
- **Approach the Green** — GIR, proximity to hole (by distance bucket,
  from fairway/rough), going for it
- **Around the Green** — Scrambling, sand saves, proximity (by distance
  and lie)
- **Putting** — Putting average, putts per round, make rates by distance
  (3’ through 25’+), GIR putting
- **Scoring** — Scoring average, birdies, eagles, bogey avoidance, par
  3/4/5 scoring, by round, front/back 9
- **Streaks** — Consecutive cuts, fairways, GIR, birdies, rounds in the
  60s
- **Money/Finishes** — Official money, career earnings, top 10s,
  victories
- **Points/Rankings** — FedExCup, world ranking, power/accuracy/putting
  ratings

## API Details

This package wraps the PGA Tour’s GraphQL and REST APIs:

- **GraphQL endpoint:** `https://orchestrator.pgatour.com/graphql`
- **REST endpoint:** `https://data-api.pgatour.com`
- **Authentication:** Uses a public API key embedded in the PGA Tour
  frontend (no user authentication required). If the frontend key
  rotates, set `Sys.setenv(PGA_API_KEY = "...")` to override the bundled
  default without reinstalling.
- **Rate limiting:** Built-in throttling at 10 requests/second.
- **Resilience:** 30-second timeout, 3-try retry on transient failures
  (408 / 429 / 5xx), and clear error messages when the API returns
  malformed responses.

Several endpoints return gzip+base64 compressed payloads. The package
handles decompression transparently.

## Dependencies

- [httr2](https://httr2.r-lib.org/) — HTTP requests
- [jsonlite](https://jeroen.r-universe.dev/jsonlite) — JSON parsing and
  base64 decoding
- [tibble](https://tibble.tidyverse.org/) — Tidy data frames
- [vctrs](https://vctrs.r-lib.org/) — Robust row/column binding
- [cli](https://cli.r-lib.org/) — User-friendly error messages

## License

MIT
