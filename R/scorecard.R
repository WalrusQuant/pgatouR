#' Get hole-by-hole scorecard
#'
#' Returns a detailed scorecard for a player in a specific tournament.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @param player_id Character. Player ID (e.g., `"39971"`).
#' @return A tibble with one row per hole per round, including hole number,
#'   par, score, yardage, status, and round-level metadata.
#' @export
#' @examples
#' \dontrun{
#' pga_scorecard("R2026475", "39971")
#' }
pga_scorecard <- function(tournament_id, player_id) {
  data <- pga_graphql_request(
    "ScorecardCompressedV3",
    list(tournamentId = tournament_id, playerId = player_id)
  )

  payload <- data$scorecardCompressedV3$payload
  if (is.null(payload)) {
    cli_abort("No scorecard data returned for player {.val {player_id}} in tournament {.val {tournament_id}}.")
  }

  parsed <- pga_decompress(payload)
  round_scores <- parsed$roundScores

  if (is.null(round_scores) || nrow(round_scores) == 0) {
    return(tibble())
  }

  all_rows <- list()

  for (r in seq_len(nrow(round_scores))) {
    round <- round_scores[r, ]
    round_num <- round$roundNumber
    course_name <- round$courseName
    round_total <- round$total
    round_score_to_par <- round$scoreToPar

    # Collect holes from firstNine and secondNine
    for (nine in c("firstNine", "secondNine")) {
      nine_data <- round[[nine]]
      if (is.null(nine_data)) next

      holes <- nine_data$holes
      if (is.null(holes)) next

      # holes is a list-column; extract the data.frame
      if (is.list(holes) && length(holes) > 0) {
        holes_df <- holes[[1]]
      } else if (is.data.frame(holes)) {
        holes_df <- holes
      } else {
        next
      }

      if (!is.data.frame(holes_df) || nrow(holes_df) == 0) next

      holes_df$round_number <- round_num
      holes_df$course_name <- course_name
      holes_df$round_total <- round_total
      holes_df$round_score_to_par <- round_score_to_par

      all_rows[[length(all_rows) + 1]] <- holes_df
    }
  }

  if (length(all_rows) == 0) {
    return(tibble())
  }

  result <- do.call(rbind, all_rows)
  result <- clean_names(as_tibble(result))

  # Reorder columns for clarity
  front_cols <- c("round_number", "hole_number", "par", "score", "status",
                  "yardage", "round_score")
  other_cols <- setdiff(names(result), front_cols)
  result[, c(front_cols[front_cols %in% names(result)], other_cols)]
}
