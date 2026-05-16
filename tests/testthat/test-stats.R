test_that("pga_stats returns a tibble with expected columns", {
  mock_graphql("statdetails")
  res <- pga_stats("02675", year = 2024)

  expect_s3_class(res, "tbl_df")
  expect_true(nrow(res) > 0)
  expect_true(all(c("stat_id", "year", "stat_title", "rank",
                    "player_id", "player_name") %in% names(res)))
  expect_true(all(res$stat_id == "02675"))
  expect_true(all(res$year == 2024L))
  expect_type(res$rank, "integer")
})

test_that("pga_stats supports multi-stat by stacking results", {
  mock_graphql("statdetails")
  res <- pga_stats(c("02675", "101"), year = 2024)
  # Each stat hits the same mock, so we get the row count twice.
  expect_true(nrow(res) > 0)
  expect_setequal(unique(res$stat_id), c("02675", "101"))
})

test_that("pga_stats supports multi-year by stacking results", {
  # Single-year baseline to compare against — same mock fixture for both calls.
  mock_graphql("statdetails")
  single <- pga_stats("02675", year = 2024)
  multi  <- pga_stats("02675", year = c(2023, 2024))
  expect_true(nrow(multi) == 2 * nrow(single))
})

test_that("pga_stats rejects invalid input", {
  expect_error(pga_stats(character(0)), class = "rlang_error")
  expect_error(pga_stats(NA_character_), class = "rlang_error")
  expect_error(pga_stats(""), class = "rlang_error")
  expect_error(pga_stats("02675", tour = "BAD"), class = "rlang_error")
})
