test_that("pga_field returns a tibble of players", {
  mock_graphql("field")
  res <- pga_field("R2026027")
  expect_s3_class(res, "tbl_df")
  expect_true(nrow(res) > 0)
  expect_true(all(c("player_id", "display_name", "role", "owgr") %in% names(res)))
})

test_that("pga_field_stats returns a tibble", {
  mock_graphql("field_stats")
  res <- pga_field_stats("R2026027")
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("player_id", "stat_type") %in% names(res)))
})
