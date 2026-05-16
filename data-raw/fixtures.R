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

# ---- REST fixtures ----
save_fixture("players",          pga_rest_request("player/list/R"))
save_fixture("schedule",         pga_rest_request(paste0("schedule/R/", YEAR)))
save_fixture("player_profile",   pga_rest_request(paste0("player/profiles/", PID)))
save_fixture("player_career",    pga_rest_request(paste0("player/profiles/", PID, "/career")))
save_fixture("player_results",   pga_rest_request(paste0("player/profiles/", PID, "/results")))
save_fixture("player_stats",     pga_rest_request(paste0("player/profiles/", PID, "/stats")))
save_fixture("player_bio",       pga_rest_request(paste0("player/profiles/", PID, "/bio")))

message("All fixtures saved to ", fixtures_dir)
