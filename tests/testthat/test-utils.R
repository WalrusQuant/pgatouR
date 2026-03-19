test_that("to_snake_case converts camelCase", {
  expect_equal(to_snake_case("playerName"), "player_name")
  expect_equal(to_snake_case("scoringData"), "scoring_data")
  expect_equal(to_snake_case("GIRPercentage"), "girpercentage")
  expect_equal(to_snake_case("firstName"), "first_name")
  expect_equal(to_snake_case("already_snake"), "already_snake")
})

test_that("validate_tour_code accepts valid codes", {
  expect_invisible(validate_tour_code("R"))
  expect_invisible(validate_tour_code("S"))
  expect_invisible(validate_tour_code("H"))
})

test_that("validate_tour_code rejects invalid codes", {
  expect_error(validate_tour_code("X"), class = "rlang_error")
  expect_error(validate_tour_code("pga"), class = "rlang_error")
})

test_that("safe_pluck returns values for valid paths", {
  x <- list(a = list(b = list(c = 42)))
  expect_equal(safe_pluck(x, "a", "b", "c"), 42)
  expect_equal(safe_pluck(x, "a", "b"), list(c = 42))
})

test_that("safe_pluck returns NULL for invalid paths", {
  x <- list(a = list(b = 1))
  expect_null(safe_pluck(x, "a", "z"))
  expect_null(safe_pluck(x, "missing"))
})

test_that("stat_ids dataset is loaded and has expected structure", {
  expect_true(is.data.frame(stat_ids))
  expect_true(nrow(stat_ids) > 200)
  expect_named(stat_ids, c("stat_id", "stat_name", "category", "subcategory"))
  # SG: Total should be in there
  expect_true("02675" %in% stat_ids$stat_id)
})
