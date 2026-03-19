#' Get current leaders snapshot
#'
#' Returns a quick leaderboard snapshot for an in-progress tournament.
#' For the full leaderboard, use [pga_leaderboard()].
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @return A tibble of current leaders.
#' @export
#' @examples
#' \dontrun{
#' pga_current_leaders("R2026475")
#' }
pga_current_leaders <- function(tournament_id) {
  data <- pga_graphql_request(
    "CurrentLeadersCompressed",
    list(tournamentId = tournament_id)
  )

  payload <- data$currentLeadersCompressed$payload
  if (is.null(payload)) {
    cli_abort("No current leaders data returned for tournament {.val {tournament_id}}.")
  }

  parsed <- pga_decompress(payload)
  players <- parsed$players

  if (is.null(players) || length(players) == 0) {
    return(tibble())
  }

  # Response is a flat data.frame
  if (is.data.frame(players)) {
    result <- tibble(
      player_id = players$id,
      first_name = players$firstName,
      last_name = players$lastName,
      display_name = players$displayName,
      country = players$country,
      position = players$position,
      total_score = players$totalScore,
      thru = players$thru,
      round_score = players$roundScore,
      round_header = players$roundHeader,
      player_state = players$playerState,
      back_nine = players$backNine,
      group_number = players$groupNumber
    )
    return(result)
  }

  # Fallback for unexpected structure
  clean_names(as_tibble(players))
}
