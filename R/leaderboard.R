#' Get tournament leaderboard
#'
#' Returns the full leaderboard for a tournament with player scores,
#' positions, and round-by-round results.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @return A tibble with one row per player.
#' @export
#' @examples
#' \dontrun{
#' pga_leaderboard("R2026475")
#' }
pga_leaderboard <- function(tournament_id) {
  data <- pga_graphql_request(
    "LeaderboardCompressedV3",
    list(leaderboardCompressedV3Id = tournament_id)
  )

  payload <- data$leaderboardCompressedV3$payload
  if (is.null(payload)) {
    cli_abort("No leaderboard data returned for tournament {.val {tournament_id}}.")
  }

  parsed <- pga_decompress(payload)
  players <- parsed$players

  if (is.null(players) || length(players) == 0) {
    return(tibble())
  }

  # Flatten player info and scoring data
  player_info <- players$player
  scoring <- players$scoringData

  # Expand rounds into separate columns
  rounds_mat <- scoring$rounds
  if (is.matrix(rounds_mat)) {
    rounds_df <- as.data.frame(rounds_mat, stringsAsFactors = FALSE)
    names(rounds_df) <- paste0("round_", seq_len(ncol(rounds_df)))
  } else {
    rounds_df <- data.frame(stringsAsFactors = FALSE)
  }

  n <- nrow(player_info)
  na_chr <- rep(NA_character_, n)
  na_lgl <- rep(NA, n)

  result <- tibble(
    player_id           = player_info$id                %||% na_chr,
    first_name          = player_info$firstName         %||% na_chr,
    last_name           = player_info$lastName          %||% na_chr,
    display_name        = player_info$displayName       %||% na_chr,
    short_name          = player_info$shortName         %||% na_chr,
    country             = player_info$country           %||% na_chr,
    country_flag        = player_info$countryFlag       %||% na_chr,
    amateur             = player_info$amateur           %||% na_lgl,
    position            = scoring$position              %||% na_chr,
    total               = scoring$total                 %||% na_chr,
    total_sort          = suppressWarnings(as.numeric(scoring$totalSort %||% na_chr)),
    total_strokes       = scoring$totalStrokes          %||% na_chr,
    thru                = scoring$thru                  %||% na_chr,
    score               = scoring$score                 %||% na_chr,
    score_sort          = suppressWarnings(as.numeric(scoring$scoreSort %||% na_chr)),
    current_round       = scoring$currentRound          %||% na_chr,
    player_state        = scoring$playerState           %||% na_chr,
    tee_time            = scoring$teeTime               %||% na_chr,
    course_id           = scoring$courseId              %||% na_chr,
    group_number        = scoring$groupNumber           %||% NA,
    back_nine           = scoring$backNine              %||% na_lgl,
    movement_direction  = scoring$movementDirection     %||% na_chr,
    movement_amount     = scoring$movementAmount        %||% na_chr,
    official            = scoring$official              %||% na_chr,
    projected           = scoring$projected             %||% na_chr
  )

  if (ncol(rounds_df) > 0) {
    result <- cbind(result, rounds_df)
    result <- as_tibble(result)
  }

  result
}

#' Get hole-by-hole scores for the field
#'
#' Returns one row per player per hole for a tournament round.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026027"`).
#' @param round Integer or `NULL`. Round number. `NULL` (default) uses the
#'   current/latest round returned by the API.
#' @return A tibble with one row per player-hole.
#' @export
#' @examples
#' \dontrun{
#' pga_leaderboard_holes("R2026027", round = 2)
#' }
pga_leaderboard_holes <- function(tournament_id, round = NULL) {
  variables <- list(tournamentId = tournament_id)
  if (!is.null(round)) variables$round <- as.integer(round)

  data <- pga_graphql_request("LeaderboardHoleByHole", variables)
  board <- data$leaderboardHoleByHole
  if (is.null(board)) {
    cli_abort("No hole-by-hole leaderboard returned for tournament {.val {tournament_id}}.")
  }

  players <- board$playerData
  if (is.null(players) || length(players) == 0) {
    return(tibble())
  }

  pieces <- lapply(players, function(p) {
    scores <- p$scores
    if (is.null(scores) || length(scores) == 0) {
      return(NULL)
    }
    tibble(
      tournament_id = board$tournamentId %||% tournament_id,
      tournament_name = board$tournamentName %||% NA_character_,
      current_round = as.integer(board$currentRound %||% NA_integer_),
      player_id = p$playerId %||% NA_character_,
      course_id = p$courseId %||% NA_character_,
      course_code = p$courseCode %||% NA_character_,
      out = p$out %||% NA_character_,
      `in` = p[["in"]] %||% NA_character_,
      total = p$total %||% NA_character_,
      total_to_par = p$totalToPar %||% NA_character_,
      hole_number = vapply(scores, function(s) as.integer(s$holeNumber %||% NA_integer_), integer(1)),
      par = vapply(scores, function(s) as.integer(s$par %||% NA_integer_), integer(1)),
      yardage = vapply(scores, function(s) as.integer(s$yardage %||% NA_integer_), integer(1)),
      score = vapply(scores, function(s) s$score %||% NA_character_, character(1)),
      status = vapply(scores, function(s) s$status %||% NA_character_, character(1)),
      round_score = vapply(scores, function(s) s$roundScore %||% NA_character_, character(1))
    )
  })

  pieces <- Filter(Negate(is.null), pieces)
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}

#' Get strokes-gained leaderboard
#'
#' Decompresses `LeaderboardStrokesCompressed` into a tibble of player
#' strokes-gained values for the tournament.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026027"`).
#' @return A tibble of player strokes-gained rows. Column names follow the
#'   upstream payload (snake_cased).
#' @export
#' @examples
#' \dontrun{
#' pga_leaderboard_strokes("R2026027")
#' }
pga_leaderboard_strokes <- function(tournament_id) {
  data <- pga_graphql_request(
    "LeaderboardStrokesCompressed",
    list(leaderboardStrokesCompressedId = tournament_id)
  )
  payload <- data$leaderboardStrokesCompressed$payload
  if (is.null(payload)) {
    cli_abort("No strokes leaderboard returned for tournament {.val {tournament_id}}.")
  }
  flatten_decompressed(pga_decompress(payload))
}

#' Get in-tournament stat table
#'
#' Wraps `LeaderboardStats`. `stats_type` is an upstream
#' `LeaderboardStatsType` value (e.g. `"OFF_THE_TEE"`, `"APPROACH"`,
#' `"AROUND_THE_GREEN"`, `"PUTTING"`, `"SCORING"`).
#'
#' @param tournament_id Character. Tournament ID.
#' @param stats_type Character or `NULL`. Stat group. `NULL` uses the API default.
#' @return A tibble with one row per player-stat (overall, plus per-round
#'   when the API returns round splits).
#' @export
pga_leaderboard_stats <- function(tournament_id, stats_type = NULL) {
  variables <- list(leaderboardStatsId = tournament_id)
  if (!is.null(stats_type)) variables$statsType <- stats_type

  data <- pga_graphql_request("LeaderboardStats", variables)
  stats <- data$leaderboardStats
  if (is.null(stats)) {
    cli_abort("No leaderboard stats returned for tournament {.val {tournament_id}}.")
  }

  flatten_leaderboard_stats(stats)
}
