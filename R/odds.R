#' Get odds to win for a tournament
#'
#' Returns betting odds for each player in the tournament field.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @return A tibble with player odds data.
#' @export
#' @examples
#' \dontrun{
#' pga_odds("R2026475")
#' }
pga_odds <- function(tournament_id) {
  data <- pga_graphql_request(
    "oddsToWinCompressed",
    list(tournamentId = tournament_id)
  )

  payload <- data$oddsToWinCompressed$payload
  if (is.null(payload)) {
    cli_abort("No odds data returned for tournament {.val {tournament_id}}.")
  }

  parsed <- pga_decompress(payload)

  # Structure varies — try common patterns
  players <- parsed$players %||% parsed$odds %||% parsed$rows
  if (is.null(players) || length(players) == 0) {
    # If the parsed data is itself a data.frame
    if (is.data.frame(parsed)) {
      return(clean_names(as_tibble(parsed)))
    }
    return(tibble())
  }

  if (is.data.frame(players)) {
    return(clean_names(as_tibble(players)))
  }

  # Fallback: return the full parsed structure as a tibble if possible
  tryCatch(
    clean_names(as_tibble(as.data.frame(players, stringsAsFactors = FALSE))),
    error = function(e) {
      cli_warn("Could not flatten odds data to tibble. Returning raw list.")
      tibble(raw_data = list(parsed))
    }
  )
}
