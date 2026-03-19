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

  result <- tibble(
    player_id = player_info$id,
    first_name = player_info$firstName,
    last_name = player_info$lastName,
    display_name = player_info$displayName,
    country = player_info$country,
    position = scoring$position,
    total = scoring$total,
    total_sort = scoring$totalSort,
    thru = scoring$thru,
    score = scoring$score,
    score_sort = scoring$scoreSort,
    current_round = scoring$currentRound,
    player_state = scoring$playerState
  )

  if (ncol(rounds_df) > 0) {
    result <- cbind(result, rounds_df)
    result <- as_tibble(result)
  }

  result
}
