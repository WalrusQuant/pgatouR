# pgatouR <img src="man/figures/logo.png" align="right" height="139" />

An R client for the PGA Tour API. Access leaderboards, player stats, scorecards, shot tracking data, tee times, FedExCup standings, betting odds, broadcast schedules, news, and video highlights — all returned as tidy tibbles.

## Installation

```r
# Install from GitHub
devtools::install_github("WalrusQuant/pgatouR")
```

## Quick Start

```r
library(pgatouR)

# Current leaderboard
pga_leaderboard("R2026475")

# Strokes Gained: Total rankings
pga_stats("02675")

# Full player directory (2,400+ players)
pga_players()

# Hole-by-hole scorecard
pga_scorecard("R2026475", "39971")

# Shot-level tracking with coordinates
pga_shot_details("R2026475", "39971", round = 1)
```

## Functions

### Live Tournament Data

| Function | Description |
|---|---|
| `pga_leaderboard(tournament_id)` | Full leaderboard with scores, positions, and round-by-round results |
| `pga_current_leaders(tournament_id)` | Quick top-15 snapshot for in-progress tournaments |
| `pga_tee_times(tournament_id)` | Tee time groupings with start tees and player assignments |
| `pga_scorecard(tournament_id, player_id)` | Hole-by-hole scorecard with par, score, yardage, and status |
| `pga_shot_details(tournament_id, player_id, round)` | Shot-by-shot tracking data with coordinates, distances, and play-by-play |
| `pga_odds(tournament_id)` | Betting odds to win for the tournament field |
| `pga_coverage(tournament_id)` | Broadcast and streaming schedule with networks and time windows |

### Statistics & Standings

| Function | Description |
|---|---|
| `pga_stats(stat_id, year, tour)` | Any of 300+ stats with full player rankings (data from 2004-2026) |
| `pga_fedex_cup(year, tour)` | FedExCup standings with projected and official rankings |
| `pga_scorecard_comparison(tournament_id, player_ids, category)` | Head-to-head stat comparison between players |

### Players & Tournaments

| Function | Description |
|---|---|
| `pga_players(tour)` | Full player directory with name, country, age, and active status |
| `pga_tournaments(ids)` | Tournament metadata including location, courses, weather, and format |

### Content

| Function | Description |
|---|---|
| `pga_news(tour, limit, offset)` | News articles with filtering by franchise, player, and pagination |
| `pga_news_franchises(tour)` | Available news categories for filtering |
| `pga_videos(player_ids, tournament_id)` | Player video highlights with filtering options |
| `pga_tourcast_videos(tournament_id, player_id, round)` | Shot-by-shot video clips for a player's round |

### Bundled Data

| Dataset | Description |
|---|---|
| `stat_ids` | Lookup table of 340 stat IDs with names, categories, and subcategories |

## Tour Codes

| Code | Tour |
|---|---|
| `"R"` | PGA Tour |
| `"S"` | PGA Tour Champions |
| `"H"` | Korn Ferry Tour |

## Tournament IDs

Tournament IDs follow the format `{tour_code}{year}{tournament_number}`, e.g., `"R2026475"` for the 2026 Valspar Championship on the PGA Tour.

You can find tournament IDs from the PGA Tour website URL or by checking the leaderboard/schedule pages. The `pga_tournaments()` function can retrieve metadata for known IDs.

## Detailed Examples

### Strokes Gained Analysis

```r
library(pgatouR)

# Get all six strokes gained categories
sg_total <- pga_stats("02675")        # SG: Total
sg_ott   <- pga_stats("02567")        # SG: Off-the-Tee
sg_app   <- pga_stats("02568")        # SG: Approach
sg_arg   <- pga_stats("02569")        # SG: Around-the-Green
sg_putt  <- pga_stats("02564")        # SG: Putting

# Check what stat you just pulled
attr(sg_total, "stat_title")
#> "SG: Total"

attr(sg_total, "tour_avg")
#> "0.000"
```

### Finding Stats

```r
# Browse the stat_ids dataset
stat_ids[stat_ids$category == "Putting", ]

# Search by name
stat_ids[grep("Driving", stat_ids$stat_name), ]

# All strokes gained stats
stat_ids[stat_ids$category == "Strokes Gained", ]
```

### Historical Data

```r
# Driving distance over the years
dd_2024 <- pga_stats("101", year = 2024)
dd_2020 <- pga_stats("101", year = 2020)
dd_2015 <- pga_stats("101", year = 2015)

# FedExCup standings from past seasons
pga_fedex_cup(2025)
pga_fedex_cup(2024)
```

### Live Tournament Tracking

```r
# Full tournament picture
tournament  <- pga_tournaments("R2026475")
leaderboard <- pga_leaderboard("R2026475")
tee_times   <- pga_tee_times("R2026475")
coverage    <- pga_coverage("R2026475")
odds        <- pga_odds("R2026475")

# Deep dive on a player
player_id <- "39971"  # Sungjae Im
scorecard  <- pga_scorecard("R2026475", player_id)
shots      <- pga_shot_details("R2026475", player_id, round = 1)
videos     <- pga_tourcast_videos("R2026475", player_id, round = 1)
```

### Player Research

```r
# Get all PGA Tour players
players <- pga_players("R")

# Filter to active players
active <- players[players$is_active, ]

# Korn Ferry Tour players
kft_players <- pga_players("H")
```

### News & Video Content

```r
# Latest news
news <- pga_news(limit = 10)

# News by category
categories <- pga_news_franchises()
power_rankings <- pga_news(franchises = "power-rankings", limit = 5)

# Player highlights
videos <- pga_videos(player_ids = "46046", tournament_id = "475")
```

## Stat Categories

The `stat_ids` dataset covers 340 stats across these categories:

- **Strokes Gained** — Total, Tee-to-Green, Off-the-Tee, Approach, Around-the-Green, Putting
- **Off The Tee** — Driving distance, accuracy, ball speed, club head speed, launch angle, spin rate
- **Approach the Green** — GIR, proximity to hole (by distance bucket, from fairway/rough), going for it
- **Around the Green** — Scrambling, sand saves, proximity (by distance and lie)
- **Putting** — Putting average, putts per round, make rates by distance (3' through 25'+), GIR putting
- **Scoring** — Scoring average, birdies, eagles, bogey avoidance, par 3/4/5 scoring, by round, front/back 9
- **Streaks** — Consecutive cuts, fairways, GIR, birdies, rounds in the 60s
- **Money/Finishes** — Official money, career earnings, top 10s, victories
- **Points/Rankings** — FedExCup, world ranking, power/accuracy/putting ratings

## API Details

This package wraps the PGA Tour's GraphQL and REST APIs:

- **GraphQL endpoint:** `https://orchestrator.pgatour.com/graphql`
- **REST endpoint:** `https://data-api.pgatour.com`
- **Authentication:** Uses a public API key embedded in the PGA Tour frontend (no user authentication required)
- **Rate limiting:** Built-in throttling at 10 requests/second

Several endpoints return gzip+base64 compressed payloads. The package handles decompression transparently.

## Dependencies

- [httr2](https://httr2.r-lib.org/) — HTTP requests
- [jsonlite](https://jeroen.r-universe.dev/jsonlite) — JSON parsing and base64 decoding
- [tibble](https://tibble.tidyverse.org/) — Tidy data frames
- [cli](https://cli.r-lib.org/) — User-friendly error messages

## License

MIT
