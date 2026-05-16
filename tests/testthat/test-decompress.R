test_that("pga_decompress rejects bad input with clear messages", {
  expect_error(pgatouR:::pga_decompress(""), "non-empty")
  expect_error(pgatouR:::pga_decompress(NA_character_), "non-empty")
  expect_error(pgatouR:::pga_decompress(c("a", "b")), "non-empty")
  expect_error(pgatouR:::pga_decompress(1L), "non-empty")
  # Valid base64 but not gzip -> should land in the gunzip error branch.
  expect_error(pgatouR:::pga_decompress("aGVsbG8="), "gunzip")
})

test_that("pga_decompress round-trips a known payload", {
  fixture <- read_fixture("leaderboard")
  payload <- fixture$leaderboardCompressedV3$payload
  expect_type(payload, "character")
  expect_true(nchar(payload) > 0)
  parsed <- pgatouR:::pga_decompress(payload)
  expect_true(!is.null(parsed))
})
