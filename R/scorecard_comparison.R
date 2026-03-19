#' Get scorecard stat comparison between players
#'
#' Returns stat comparison categories for players in a tournament.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @param player_ids Character vector. Player IDs to compare.
#' @param category Character. Comparison category. Common values:
#'   `"SCORING"`, `"DRIVING"`, `"APPROACH"`, `"SHORT_GAME"`, `"PUTTING"`.
#'   Defaults to `"SCORING"`.
#' @return A tibble of comparison data with available category pills.
#' @export
#' @examples
#' \dontrun{
#' pga_scorecard_comparison("R2026475", c("39971", "46046"), "SCORING")
#' }
pga_scorecard_comparison <- function(tournament_id, player_ids,
                                     category = "SCORING") {
  data <- pga_graphql_request(
    "ScorecardStatsComparisonCategories",
    list(
      tournamentId = tournament_id,
      playerIds = as.list(player_ids),
      category = category
    )
  )

  comparison <- data$scorecardStatsComparison
  if (is.null(comparison)) {
    cli_abort("No comparison data returned for tournament {.val {tournament_id}}.")
  }

  pills <- comparison$categoryPills
  if (is.null(pills) || length(pills) == 0) {
    return(tibble(
      tournament_id = comparison$tournamentId,
      category = comparison$category
    ))
  }

  if (is.data.frame(pills)) {
    result <- clean_names(as_tibble(pills))
  } else {
    result <- tibble(
      display_text = vapply(pills, function(p) p$displayText %||% NA_character_, character(1)),
      category = vapply(pills, function(p) p$category %||% NA_character_, character(1))
    )
  }

  attr(result, "tournament_id") <- comparison$tournamentId
  attr(result, "selected_category") <- comparison$category

  result
}
