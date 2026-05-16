test_that("pga_players returns a tibble", {
  mock_rest("players")
  res <- pga_players()
  expect_s3_class(res, "tbl_df")
  expect_true(nrow(res) > 0)
})
