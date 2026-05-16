test_that("pga_tee_times returns a tibble", {
  mock_graphql("tee_times")
  res <- pga_tee_times("R2024003")
  expect_s3_class(res, "tbl_df")
  if (nrow(res) > 0) {
    expect_true(all(c("round_number", "player_id", "tee_time") %in% names(res)))
  }
})

test_that("pga_shot_details returns a tibble", {
  mock_graphql("shot_details")
  res <- pga_shot_details("R2024003", "52955", 1)
  expect_s3_class(res, "tbl_df")
})

test_that("pga_current_leaders returns a tibble", {
  mock_graphql("current_leaders")
  res <- pga_current_leaders("R2024003")
  expect_s3_class(res, "tbl_df")
})

test_that("pga_odds returns a tibble", {
  mock_graphql("odds")
  res <- pga_odds("R2024003")
  expect_s3_class(res, "tbl_df")
})

test_that("pga_fedex_cup returns a tibble", {
  mock_graphql("tourcupsplit")
  res <- pga_fedex_cup(2024)
  expect_s3_class(res, "tbl_df")
})
