test_that("pga_news returns a tibble", {
  mock_graphql("news")
  res <- pga_news()
  expect_s3_class(res, "tbl_df")
})

test_that("pga_news_franchises returns a tibble", {
  mock_graphql("newsfranchises")
  res <- pga_news_franchises()
  expect_s3_class(res, "tbl_df")
})

test_that("pga_videos returns a tibble", {
  mock_graphql("videos")
  res <- pga_videos()
  expect_s3_class(res, "tbl_df")
})

test_that("pga_tourcast_videos returns a tibble", {
  mock_graphql("tourcastvideos")
  res <- pga_tourcast_videos("R2024003", "52955", round = 1)
  expect_s3_class(res, "tbl_df")
})
