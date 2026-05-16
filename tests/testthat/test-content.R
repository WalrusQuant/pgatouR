test_that("pga_content decompresses and returns a parsed list", {
  mock_graphql("content")
  res <- pga_content("/content/dam/pga-tour/fragments/pages/fedexcup/fedexcup-overview")
  expect_type(res, "list")
  expect_true(length(res) > 0)
})

test_that("pga_content rejects invalid input", {
  expect_error(pga_content(""),       class = "rlang_error")
  expect_error(pga_content(NA_character_), class = "rlang_error")
  expect_error(pga_content(character(0)),  class = "rlang_error")
})

test_that("pga_odds_interactivity returns the raw configuration list", {
  mock_rest("odds_interactivity")
  res <- pga_odds_interactivity()
  expect_type(res, "list")
  expect_true(length(res) > 0)
})

test_that("pga_speed_rounds returns the raw video-index list", {
  mock_rest("speed_rounds")
  res <- pga_speed_rounds("R")
  expect_type(res, "list")
  expect_true(length(res) > 0)
})

test_that("pga_speed_rounds validates the tour code", {
  expect_error(pga_speed_rounds("BAD"), class = "rlang_error")
})
