test_that("pga_leaderboard_holes returns player-hole rows", {
  mock_graphql("leaderboard_holes")
  res <- pga_leaderboard_holes("R2026027", round = 2)
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("player_id", "hole_number", "score") %in% names(res)))
})

test_that("pga_leaderboard_strokes returns a tibble", {
  mock_graphql("leaderboard_strokes")
  res <- pga_leaderboard_strokes("R2026027")
  expect_s3_class(res, "tbl_df")
})

test_that("pga_leaderboard_stats returns a tibble", {
  mock_graphql("leaderboard_stats")
  res <- pga_leaderboard_stats("R2026027")
  expect_s3_class(res, "tbl_df")
})

test_that("pga_stat_catalog and pga_stat_leaders parse StatOverview", {
  mock_graphql("stat_overview")
  catalog <- pga_stat_catalog(year = 2026)
  leaders <- pga_stat_leaders(year = 2026)
  expect_s3_class(catalog, "tbl_df")
  expect_s3_class(leaders, "tbl_df")
  expect_true(all(c("stat_id", "stat_name", "category") %in% names(catalog)))
})

test_that("pga_scorecard_stats returns a tibble", {
  mock_graphql("scorecard_stats")
  res <- pga_scorecard_stats("R2026027", "46046")
  expect_s3_class(res, "tbl_df")
})

test_that("pga_player_finish_stats returns event rows", {
  mock_graphql("player_finish_stats")
  res <- pga_player_finish_stats("46046", "02675")
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("player_id", "stat_id", "value") %in% names(res)))
})

test_that("pga_group_locations returns a tibble", {
  mock_graphql("group_locations")
  res <- pga_group_locations("R2026027", 3)
  expect_s3_class(res, "tbl_df")
})

test_that("pga_shot_scatter returns a tibble", {
  mock_graphql("scatter")
  res <- pga_shot_scatter("R2026027", 513, 1)
  expect_s3_class(res, "tbl_df")
})

test_that("pga_odds_markets returns market rows", {
  mock_rest("odds_markets")
  res <- pga_odds_markets("R2026027")
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("market_type", "display_name") %in% names(res)))
})

test_that("pga_odds_player returns line rows", {
  mock_rest("odds_player")
  res <- pga_odds_player("R2026027", "46046")
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("odds", "market_type") %in% names(res)))
})
