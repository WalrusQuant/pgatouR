# Capture real API responses as RDS fixtures used by the offline test suite.
# Run this manually whenever the upstream API shape changes:
#   Rscript data-raw/fixtures.R
#
# Each fixture stores the *raw* output of pga_graphql_request() or
# pga_rest_request() — i.e. the parsed body before any parser massages it.
# Tests then mock those transports to return the fixture, so the parsers are
# exercised offline.

devtools::load_all(quiet = TRUE)
fixtures_dir <- file.path("tests", "testthat", "fixtures")
dir.create(fixtures_dir, recursive = TRUE, showWarnings = FALSE)

save_fixture <- function(name, obj) {
  path <- file.path(fixtures_dir, paste0(name, ".rds"))
  saveRDS(obj, path, version = 2)
  message("Saved ", path)
}

# Pick a finished tournament + a well-known player so fixtures are stable.
TID    <- "R2024003"        # Sentry, 2024
PID    <- "52955"           # Ludvig Aberg
YEAR   <- 2024
TOUR   <- "R"
STATID <- "02675"           # SG: Total

# ---- GraphQL fixtures ----
save_fixture("statdetails", pga_graphql_request(
  "StatDetails", list(tourCode = TOUR, statId = STATID, year = YEAR)
))
save_fixture("tournaments", pga_graphql_request(
  "Tournaments", list(ids = list(TID))
))
save_fixture("tourcupsplit", pga_graphql_request(
  "TourCupSplit", list(tourCode = TOUR, id = "02671", year = YEAR)
))
save_fixture("coverage", pga_graphql_request(
  "Coverage", list(tournamentId = TID)
))
save_fixture("news", pga_graphql_request(
  "NewsArticles", list(tour = TOUR, limit = 5L, offset = 0L)
))
save_fixture("newsfranchises", pga_graphql_request(
  "NewsFranchises", list(tourCode = TOUR, allFranchises = FALSE)
))
save_fixture("scstats", pga_graphql_request(
  "ScorecardStatsComparisonCategories",
  list(tournamentId = TID, playerIds = list(PID), category = "SCORING")
))
save_fixture("playertournamentstatus", pga_graphql_request(
  "getPlayerTournamentStatus", list(playerId = PID)
))
save_fixture("videos", pga_graphql_request(
  "Videos", list(tourCode = TOUR, limit = 5L, offset = 0L)
))
save_fixture("tourcastvideos", pga_graphql_request(
  "TourcastVideos", list(tournamentId = TID, playerId = PID, round = 1L)
))

# Compressed: save BOTH the graphql wrapper AND the decompressed inner payload,
# since some parsers handle decompression themselves.
lb <- pga_graphql_request("LeaderboardCompressedV3", list(leaderboardCompressedV3Id = TID))
save_fixture("leaderboard", lb)
save_fixture("leaderboard_decompressed", pga_decompress(lb$leaderboardCompressedV3$payload))

sc <- pga_graphql_request("ScorecardCompressedV3",
                          list(tournamentId = TID, playerId = PID))
save_fixture("scorecard", sc)

sd <- pga_graphql_request("shotDetailsV4Compressed",
                          list(tournamentId = TID, playerId = PID, round = 1L))
save_fixture("shot_details", sd)

tt <- pga_graphql_request("TeeTimesCompressedV2",
                          list(teeTimesCompressedV2Id = TID))
save_fixture("tee_times", tt)

cl <- pga_graphql_request("CurrentLeadersCompressed",
                          list(tournamentId = TID))
save_fixture("current_leaders", cl)

od <- pga_graphql_request("oddsToWinCompressed",
                          list(tournamentId = TID))
save_fixture("odds", od)

# ---- Content / odds / speed-rounds fixtures ----
save_fixture("content", pga_graphql_request(
  "GenericContentCompressed",
  list(path = "/content/dam/pga-tour/fragments/pages/fedexcup/fedexcup-overview")
))
save_fixture("odds_interactivity", pga_rest_request("odds/interactivity"))
save_fixture("speed_rounds", pga_rest_request("content/watch/speedRounds/R"))

# ---- REST fixtures ----
save_fixture("players",          pga_rest_request("player/list/R"))
save_fixture("schedule",         pga_rest_request(paste0("schedule/R/", YEAR)))
save_fixture("player_profile",   pga_rest_request(paste0("player/profiles/", PID)))
save_fixture("player_career",    pga_rest_request(paste0("player/profiles/", PID, "/career")))
save_fixture("player_results",   pga_rest_request(paste0("player/profiles/", PID, "/results")))
save_fixture("player_stats",     pga_rest_request(paste0("player/profiles/", PID, "/stats")))
save_fixture("player_bio",       pga_rest_request(paste0("player/profiles/", PID, "/bio")))

# ---- 2026 endpoint-audit fixtures (current event + stable historical) ----
TID26  <- "R2026027"        # FedEx St. Jude, 2026
PID26  <- "46046"           # Scottie Scheffler
COURSE <- "513"             # TPC Southwind

save_fixture("field", pga_graphql_request(
  "Field", list(fieldId = TID26, includeWithdrawn = TRUE)
))
save_fixture("field_stats", pga_graphql_request(
  "FieldStats", list(tournamentId = TID26, fieldStatType = "COURSE_FIT")
))
save_fixture("course_stats", pga_graphql_request(
  "CourseStats", list(tournamentId = TID26)
))
save_fixture("course_stats_overview", pga_graphql_request(
  "CourseStatsOverview", list(tourCode = TOUR, year = 2026L)
))
save_fixture("hole_details", pga_graphql_request(
  "HoleDetails", list(tournamentId = TID26, courseId = COURSE, hole = 1L)
))
save_fixture("leaderboard_holes", pga_graphql_request(
  "LeaderboardHoleByHole", list(tournamentId = TID26, round = 2L)
))
save_fixture("leaderboard_strokes", pga_graphql_request(
  "LeaderboardStrokesCompressed", list(leaderboardStrokesCompressedId = TID26)
))
save_fixture("leaderboard_stats", pga_graphql_request(
  "LeaderboardStats", list(leaderboardStatsId = TID26)
))
save_fixture("tournament_overview", pga_graphql_request(
  "TournamentOverview", list(tournamentId = TID26)
))
save_fixture("tournament_past_results", pga_graphql_request(
  "TournamentPastResults", list(tournamentPastResultsId = TID26, year = 2025L)
))
save_fixture("weather", pga_graphql_request(
  "Weather", list(tournamentId = TID26)
))
save_fixture("signature_standings", pga_graphql_request(
  "SignatureStandings", list(tourCode = TOUR)
))
save_fixture("priority_rankings", pga_graphql_request(
  "PriorityRankings", list(tourCode = TOUR, year = 2026L)
))
save_fixture("bubble", pga_graphql_request(
  "Bubble", list(tourCode = TOUR, tournamentId = TID26)
))
save_fixture("cup_standings", pga_graphql_request(
  "TourCupStandings", list(tour = TOUR, year = 2026L)
))
save_fixture("stat_overview", pga_graphql_request(
  "StatOverview", list(tourCode = TOUR, year = 2026L)
))
save_fixture("all_time_record_categories", pga_graphql_request(
  "AllTimeRecordCategories", list(tourCode = TOUR)
))
save_fixture("university_rankings", pga_graphql_request(
  "UniversityRankings", list(year = 2026L)
))
save_fixture("scorecard_stats", pga_graphql_request(
  "ScorecardStatsV3Compressed",
  list(scorecardStatsV3CompressedId = TID26, playerId = PID26)
))
save_fixture("player_finish_stats", pga_graphql_request(
  "PlayerFinishStats",
  list(playerId = PID26, statId = STATID, tourCode = TOUR)
))
save_fixture("group_locations", pga_graphql_request(
  "GroupLocations", list(tournamentId = TID26, round = 3L)
))
save_fixture("scatter", pga_graphql_request(
  "ScatterDataCompressed",
  list(tournamentId = TID26, course = as.integer(COURSE), hole = 1L)
))
save_fixture("odds_markets", pga_rest_request(paste0("odds/tournament/", TID26)))
save_fixture("odds_player", pga_rest_request(
  paste0("odds/tournament/", TID26, "/player/", PID26)
))
save_fixture("web_config", pga_config_request("web-config"))

atr_cats <- pga_graphql_request("AllTimeRecordCategories", list(tourCode = TOUR))
first_record <- tryCatch(
  atr_cats$allTimeRecordCategories$categories[[1]]$subCategories[[1]]$statistics[[1]]$recordId,
  error = function(e) NULL
)
if (!is.null(first_record)) {
  save_fixture("all_time_records", pga_graphql_request(
    "AllTimeRecordStat", list(tourCode = TOUR, recordId = first_record)
  ))
}

message("All fixtures saved to ", fixtures_dir)
