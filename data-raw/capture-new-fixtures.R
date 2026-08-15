# Capture only the 2026 endpoint-audit fixtures (not the full historic set).
# Run from the package root: Rscript data-raw/capture-new-fixtures.R

devtools::load_all(quiet = TRUE)
fixtures_dir <- file.path("tests", "testthat", "fixtures")
dir.create(fixtures_dir, recursive = TRUE, showWarnings = FALSE)

save_fixture <- function(name, obj) {
  path <- file.path(fixtures_dir, paste0(name, ".rds"))
  saveRDS(obj, path, version = 2)
  message("Saved ", path)
}

TOUR   <- "R"
STATID <- "02675"
TID26  <- "R2026027"
PID26  <- "46046"
COURSE <- "513"

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

message("New fixtures saved to ", fixtures_dir)
