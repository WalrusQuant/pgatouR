test_that("pga_scorecard returns a tibble or empty tibble", {
  mock_graphql("scorecard")
  res <- pga_scorecard("R2024003", "52955")
  expect_s3_class(res, "tbl_df")
  if (nrow(res) > 0) {
    expect_true("round_number" %in% names(res))
    expect_true("hole_number" %in% names(res) || "par" %in% names(res))
  }
})

test_that("pga_scorecard_comparison returns a tibble", {
  mock_graphql("scstats")
  res <- pga_scorecard_comparison("R2024003", c("52955"), "SCORING")
  expect_s3_class(res, "tbl_df")
})
