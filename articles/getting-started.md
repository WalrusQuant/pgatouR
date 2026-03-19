# Getting Started with pgatouR

pgatouR gives you access to the PGA Tour’s data through a clean set of R
functions. Every function returns a tibble, so the data is immediately
ready for analysis with dplyr, ggplot2, or whatever you prefer.

This vignette walks through the main use cases.

## Installation

``` r
devtools::install_github("WalrusQuant/pgatouR")
```

``` r
library(pgatouR)
```

## Tournament IDs

Most functions need a tournament ID. These follow the format
`{tour_code}{year}{number}`:

- `"R2026475"` — 2026 Valspar Championship (PGA Tour)
- `"R2026003"` — 2026 Sentry (PGA Tour)
- `"S2026003"` — A Champions Tour event

You can find these from PGA Tour URLs or by using
[`pga_schedule()`](https://walrusquant.github.io/pgatouR/reference/pga_schedule.md)
to list all tournaments for a season:

``` r
# Full season schedule with dates, purse, course, champion
pga_schedule(2026)
#> # A tibble: 48 × 15
#>    tournament_id tournament_name       display_date status    purse     ...
#>    <chr>         <chr>                 <chr>        <chr>     <chr>     ...
#>  1 R2026006      Sony Open in Hawaii   Jan 15 - 18  COMPLETED $9,100,000
#>  2 R2026002      The American Express  Jan 22 - 25  COMPLETED $9,200,000
#>  3 R2026004      Farmers Insurance Op… Jan 29 - F…  COMPLETED $9,600,000
#>  ...
```

The tour code prefix tells you which tour:

| Code | Tour               |
|------|--------------------|
| `R`  | PGA Tour           |
| `S`  | PGA Tour Champions |
| `H`  | Korn Ferry Tour    |

## Tracking a Live Tournament

### Leaderboard

The leaderboard is the starting point for any tournament. It returns
every player in the field with their scores.

``` r
lb <- pga_leaderboard("R2026475")
lb
#> # A tibble: 135 × 17
#>    player_id first_name last_name display_name  country position total thru
#>    <chr>     <chr>      <chr>     <chr>         <chr>   <chr>    <chr> <chr>
#>  1 39971     Sungjae    Im        Sungjae Im    KOR     1        -7    F*
#>  2 27064     Brandt     Snedeker  Brandt Snede… USA     2        -6    F
#>  3 56630     Davis      Thompson  Davis Thomps… USA     T3       -5    F
#>  4 39997     Jordan     Spieth    Jordan Spieth USA     T3       -5    7
#>  ...
```

For a quick snapshot of just the top 15, use
[`pga_current_leaders()`](https://walrusquant.github.io/pgatouR/reference/pga_current_leaders.md):

``` r
pga_current_leaders("R2026475")
```

### Tee Times

See who’s grouped together and when they tee off:

``` r
tt <- pga_tee_times("R2026475")
tt
#> # A tibble: 270 × 12
#>    round_number tee_time            start_tee display_name    group_number
#>           <int> <dttm>                  <int> <chr>                  <int>
#>  1            1 2026-03-19 07:35:00         1 Alex Smalley               1
#>  2            1 2026-03-19 07:35:00         1 Justin Lower               1
#>  3            1 2026-03-19 07:35:00         1 Max McGreevy               1
#>  ...
```

Tee times are returned as proper `POSIXct` timestamps in the
tournament’s local timezone.

### Tournament Metadata

Get the full picture — name, location, dates, format, current weather:

``` r
t <- pga_tournaments("R2026475")
t$tournament_name
#> "Valspar Championship"

t$weather_condition
#> "DAY_PARTLY_CLOUDY"

t$weather_temp_f
#> "73°F"
```

The `courses` column is a list-column containing a tibble of course
details for each tournament.

### Broadcast Schedule

See what’s live and what’s coming up:

``` r
pga_coverage("R2026475")
#> # A tibble: 16 × 7
#>    coverage_type          stream_title            round_number live_status
#>    <chr>                  <chr>                          <int> <chr>
#>  1 BroadcastFullTelecast  Round 1 - Broadcast                1 LIVE
#>  2 BroadcastFullTelecast  Main Feed                          2 UPCOMING
#>  3 BroadcastFeaturedGroup Marquee Group - S. Ry…             2 UPCOMING
#>  ...
```

### Odds

``` r
odds <- pga_odds("R2026475")
odds
#> # A tibble: 135 × 5
#>    player_id odds    odds_sort odds_direction option_id
#>    <chr>     <chr>       <dbl> <chr>          <chr>
#>  1 34046     +650          7.5 UP             18776
#>  2 36689     +6000        61   DOWN           18776
#>  ...
```

## Player Deep Dive

### Scorecard

Get a player’s hole-by-hole results. Each row is one hole in one round:

``` r
sc <- pga_scorecard("R2026475", "39971")
sc
#> # A tibble: 18 × 11
#>    round_number hole_number   par score status yardage round_score
#>           <int>       <int> <int> <chr> <chr>    <int> <chr>
#>  1            1          10     4 3     BIRDIE     437 -1
#>  2            1          11     5 3     EAGLE      561 -3
#>  3            1          12     4 3     BIRDIE     370 -4
#>  ...
```

The `status` column gives you the result on each hole (EAGLE, BIRDIE,
PAR, BOGEY, etc.), and `round_score` is the running score relative to
par.

### Shot-Level Tracking

This is the most granular data available — every shot a player hits,
with distances, play-by-play descriptions, and coordinate data for
visualization:

``` r
shots <- pga_shot_details("R2026475", "39971", round = 1)
shots
#> # A tibble: 65 × 15+
#>    hole_number stroke_number play_by_play                        distance
#>          <int>         <int> <chr>                               <chr>
#>  1          10             1 303 yds to left tree outline, 136…  303 yds
#>  2          10             2 134 yds to left green, 10 ft 2 in… 134 yds
#>  3          10             3 In the hole                         10 ft 2 in.
#>  ...
```

The response includes coordinate columns (prefixed with
`leftToRightCoords` and `bottomToTopCoords`) containing `x`, `y`,
`tourcastX`, `tourcastY`, and `tourcastZ` values for both the `from` and
`to` positions of each stroke. These can be used to plot shot patterns
on a course map.

### Video Highlights

Get video clips for a specific player in a tournament:

``` r
pga_videos(player_ids = "39971", tournament_id = "475")
#> # A tibble: 18 × 17
#>    title                                  duration_secs hole_number pub_date
#>    <chr>                                          <int> <chr>       <dttm>
#>  1 Sungjae Im hits 117-yard approach to…             25 5           2026-03-19 16:42:12
#>  2 Sungjae Im sinks 44-foot birdie putt…             16 3           2026-03-19 16:05:19
#>  ...
```

Note:
[`pga_videos()`](https://walrusquant.github.io/pgatouR/reference/pga_videos.md)
takes the numeric tournament ID (`"475"`) without the tour code prefix,
while most other functions use the full ID (`"R2026475"`).

For shot-by-shot video clips (one clip per stroke in a round):

``` r
pga_tourcast_videos("R2026475", "39971", round = 1)
```

## Statistics

### Pulling Stats

pgatouR gives you access to 300+ PGA Tour statistics going back to 2004.
Every stat has a unique ID:

``` r
# Strokes Gained: Total
sg <- pga_stats("02675")
sg
#> # A tibble: 195 × 7+
#>     rank player_name       country          ...
#>    <int> <chr>             <chr>            ...
#>  1     1 Jacob Bridgeman   United States    ...
#>  2     2 Jake Knapp        United States    ...
#>  3     3 Scottie Scheffler United States    ...
#>  ...
```

The result includes metadata as attributes:

``` r
attr(sg, "stat_title")       # "SG: Total"
attr(sg, "stat_description") # Full description text
attr(sg, "tour_avg")         # "0.000"
attr(sg, "year")             # 2026
```

### Finding Stat IDs

The package includes a bundled `stat_ids` dataset with all 340 known
stat IDs:

``` r
# All strokes gained stats
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

# Search by name
stat_ids[grep("Driving Distance", stat_ids$stat_name), ]

# See all categories
unique(stat_ids$category)
#> "Strokes Gained"    "Off The Tee"       "Approach the Green"
#> "Around the Green"  "Putting"           "Scoring"
#> "Streaks"           "Money/Finishes"    "Points/Rankings"
```

### Historical Comparisons

Pull the same stat across multiple years:

``` r
dd_2026 <- pga_stats("101", year = 2026)  # Driving Distance
dd_2020 <- pga_stats("101", year = 2020)
dd_2015 <- pga_stats("101", year = 2015)
```

### Common Stat IDs

Here are the ones you’ll probably use most:

| Stat ID | Stat                            |
|---------|---------------------------------|
| `02675` | SG: Total                       |
| `02674` | SG: Tee-to-Green                |
| `02567` | SG: Off-the-Tee                 |
| `02568` | SG: Approach the Green          |
| `02569` | SG: Around-the-Green            |
| `02564` | SG: Putting                     |
| `101`   | Driving Distance                |
| `102`   | Driving Accuracy Percentage     |
| `103`   | Greens in Regulation Percentage |
| `130`   | Scrambling                      |
| `104`   | Putting Average                 |
| `120`   | Scoring Average (Adjusted)      |

## Season Schedule

Get the full season schedule with dates, purse, course info, champions,
and FedExCup points:

``` r
schedule <- pga_schedule(2026)
schedule
#> # A tibble: 48 × 15
#>    tournament_id tournament_name       display_date status    purse
#>    <chr>         <chr>                 <chr>        <chr>     <chr>
#>  1 R2026006      Sony Open in Hawaii   Jan 15 - 18  COMPLETED $9,100,000
#>  2 R2026002      The American Express  Jan 22 - 25  COMPLETED $9,200,000
#>  ...

# See champions and earnings for completed events
schedule[schedule$status == "COMPLETED",
         c("tournament_name", "champion", "champion_earnings")]

# Use tournament IDs with other functions
pga_leaderboard("R2026006")

# Past seasons work too
pga_schedule(2025)
```

## FedExCup Standings

``` r
fc <- pga_fedex_cup(2026)
fc
#> # A tibble: 192 × 14
#>    display_name      this_week_rank projected_points ...
#>    <chr>             <chr>          <chr>            ...
#>  1 Jacob Bridgeman   1              1,403.981        ...
#>  2 Cameron Young     2              1,323.014        ...
#>  3 Akshay Bhatia     3              1,224.306        ...
#>  ...
```

## Player Directory

The full player directory has 2,400+ players across all tours:

``` r
players <- pga_players("R")
nrow(players)
#> 2486

# Filter to active players
active <- players[players$is_active, ]
nrow(active)

# Other tours
champions <- pga_players("S")
korn_ferry <- pga_players("H")
```

## News

``` r
# Latest articles
news <- pga_news(limit = 10)
news[, c("headline", "publish_date", "franchise_display_name")]

# See available categories
pga_news_franchises()
#> # A tibble: 7 × 2
#>   franchise        franchise_label
#>   <chr>            <chr>
#> 1 latest           Latest
#> 2 power-rankings   Power Rankings
#> 3 expert-picks     Expert Picks
#> 4 equipment-report Equipment
#> 5 tour-insider     Tour Insider
#> 6 needtoknow       Need to Know
#> 7 daily-wrapup     Daily Wrap Up

# Filter by category
pga_news(franchises = "power-rankings", limit = 5)
```

## Tips

- **Rate limiting** is built in at 10 requests/second. You don’t need to
  add delays.
- **Compressed payloads** (leaderboards, scorecards, tee times, shot
  details, odds) are decompressed automatically. You always get a clean
  tibble.
- **Error messages** use the cli package and will tell you exactly what
  went wrong (bad tournament ID, API errors, etc.).
- **`stat_ids`** is lazy-loaded — just type `stat_ids` to access it, no
  [`data()`](https://rdrr.io/r/utils/data.html) call needed.
- The **`@return`** section in each function’s help page
  ([`?pga_leaderboard`](https://walrusquant.github.io/pgatouR/reference/pga_leaderboard.md))
  describes the exact columns you’ll get back.
