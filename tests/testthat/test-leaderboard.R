test_that("pga_leaderboard returns a tibble", {
  mock_graphql("leaderboard")
  res <- pga_leaderboard("R2024003")
  expect_s3_class(res, "tbl_df")
  expect_true(nrow(res) > 0)
  expect_true(all(c("player_id", "first_name", "last_name", "position") %in% names(res)))
})
