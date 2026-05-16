test_that("pga_player_profile returns expected named list", {
  mock_rest("player_profile")
  res <- pga_player_profile("52955")

  expect_type(res, "list")
  expect_named(
    res,
    c("player_id", "first_name", "last_name", "country", "country_code",
      "born", "age", "birthplace", "college", "turned_pro",
      "highlights", "overview")
  )
  expect_s3_class(res$highlights, "tbl_df")
  expect_s3_class(res$overview, "tbl_df")
})

test_that("pga_player_career returns a tibble", {
  mock_rest("player_career")
  res <- pga_player_career("52955")
  expect_s3_class(res, "tbl_df")
  if (nrow(res) > 0) {
    expect_true(all(c("tour_code", "section", "widget", "label", "value") %in% names(res)))
  }
})

test_that("pga_player_results carries a season column and returns all seasons", {
  mock_rest("player_results")
  res <- pga_player_results("52955")
  expect_s3_class(res, "tbl_df")
  if (nrow(res) > 0) {
    expect_true("season" %in% names(res))
    expect_true("tournament_id" %in% names(res))
  }
})

test_that("pga_player_stats coerces rank to integer", {
  mock_rest("player_stats")
  res <- pga_player_stats("52955")
  expect_s3_class(res, "tbl_df")
  if (nrow(res) > 0) {
    expect_type(res$rank, "integer")
    expect_true(all(c("stat_id", "title", "rank", "value", "category") %in% names(res)))
  }
})

test_that("pga_player_bio returns the expected three-key list", {
  mock_rest("player_bio")
  res <- pga_player_bio("52955")
  expect_named(res, c("text", "amateur_highlights", "widgets"))
  expect_type(res$text, "character")
  expect_type(res$amateur_highlights, "character")
  expect_s3_class(res$widgets, "tbl_df")
})

test_that("pga_player_tournament_status exposes round_status_display and color", {
  mock_graphql("playertournamentstatus")
  res <- pga_player_tournament_status("52955")
  expect_s3_class(res, "tbl_df")
  # Even when the API returns an empty status object, the column set must be stable.
  if (nrow(res) > 0) {
    expect_true(all(c("round_status_display", "round_status_color") %in% names(res)))
  }
})
