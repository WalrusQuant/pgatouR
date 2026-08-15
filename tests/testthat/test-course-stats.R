test_that("pga_course_stats returns a tibble", {
  mock_graphql("course_stats")
  res <- pga_course_stats("R2026027")
  expect_s3_class(res, "tbl_df")
  expect_true(all(c("course_id", "hole_number", "par") %in% names(res)))
})

test_that("pga_course_stats_overview returns a tibble", {
  mock_graphql("course_stats_overview")
  res <- pga_course_stats_overview()
  expect_s3_class(res, "tbl_df")
})

test_that("pga_hole_details returns a named list", {
  mock_graphql("hole_details")
  res <- pga_hole_details("R2026027", "513", 1)
  expect_type(res, "list")
  expect_true(all(c("stats", "groups") %in% names(res)))
  expect_s3_class(res$stats, "tbl_df")
})
