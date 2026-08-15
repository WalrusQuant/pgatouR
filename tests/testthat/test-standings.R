test_that("pga_signature_standings returns a tibble", {
  mock_graphql("signature_standings")
  res <- pga_signature_standings()
  expect_s3_class(res, "tbl_df")
})

test_that("pga_priority_rankings returns category-player rows", {
  mock_graphql("priority_rankings")
  res <- pga_priority_rankings(year = 2026)
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("category", "player_id", "display_name") %in% names(res)))
})

test_that("pga_bubble returns a tibble (possibly empty)", {
  mock_graphql("bubble")
  res <- pga_bubble("R2026027")
  expect_s3_class(res, "tbl_df")
})

test_that("pga_cup_standings returns ranking rows", {
  mock_graphql("cup_standings")
  res <- pga_cup_standings(2026)
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("player_id", "position", "total") %in% names(res)))
})

test_that("pga_all_time_record_categories returns record ids", {
  mock_graphql("all_time_record_categories")
  res <- pga_all_time_record_categories()
  expect_s3_class(res, "tbl_df")
  expect_true("record_id" %in% names(res))
})

test_that("pga_all_time_records returns a tibble", {
  mock_graphql("all_time_records")
  res <- pga_all_time_records("dummy")
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("record_id", "player_id") %in% names(res)))
})

test_that("pga_university_rankings returns a tibble", {
  mock_graphql("university_rankings")
  res <- pga_university_rankings(year = 2026)
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("player_id", "school", "rank") %in% names(res)))
})
