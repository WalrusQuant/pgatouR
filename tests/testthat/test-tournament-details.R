test_that("pga_current_tournament reads web-config", {
  mock_config("web_config")
  res <- pga_current_tournament("R")
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("tour", "tournament_id", "leaderboard_id") %in% names(res)))
  expect_true(nrow(res) >= 1)
})

test_that("pga_tournament_overview returns a named list", {
  mock_graphql("tournament_overview")
  res <- pga_tournament_overview("R2026027")
  expect_type(res, "list")
  expect_true(all(c("overview", "champions", "courses") %in% names(res)))
  expect_s3_class(res$overview, "tbl_df")
})

test_that("pga_tournament_past_results returns a tibble", {
  mock_graphql("tournament_past_results")
  res <- pga_tournament_past_results("R2026027", year = 2025)
  expect_s3_class(res, "tbl_df")
  expect_true(nrow(res) > 0)
  expect_true(all(c("player_id", "display_name", "position") %in% names(res)))
})

test_that("pga_weather returns hourly and/or daily rows", {
  mock_graphql("weather")
  res <- pga_weather("R2026027")
  expect_s3_class(res, "tbl_df")
  expect_true("scope" %in% names(res))
})
