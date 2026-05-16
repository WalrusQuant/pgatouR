test_that("pga_tournaments returns a tibble", {
  mock_graphql("tournaments")
  res <- pga_tournaments("R2024003")
  expect_s3_class(res, "tbl_df")
})

test_that("pga_schedule returns a tibble", {
  mock_rest("schedule")
  res <- pga_schedule(2024)
  expect_s3_class(res, "tbl_df")
})

test_that("pga_coverage returns a tibble", {
  mock_graphql("coverage")
  res <- pga_coverage("R2024003")
  expect_s3_class(res, "tbl_df")
})
