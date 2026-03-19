#' Get shot-level tracking data
#'
#' Returns shot-by-shot data with coordinates for a player's round,
#' including distance, stroke type, play-by-play descriptions, and
#' coordinate data for shot visualization.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @param player_id Character. Player ID (e.g., `"39971"`).
#' @param round Integer. Round number (1-4).
#' @param include_radar Logical. Include radar data. Defaults to `FALSE`.
#' @return A tibble with one row per stroke, including hole-level context.
#' @export
#' @examples
#' \dontrun{
#' pga_shot_details("R2026475", "39971", round = 1)
#' }
pga_shot_details <- function(tournament_id, player_id, round,
                             include_radar = FALSE) {
  data <- pga_graphql_request(
    "shotDetailsV4Compressed",
    list(
      tournamentId = tournament_id,
      playerId = player_id,
      round = as.integer(round),
      includeRadar = include_radar
    )
  )

  payload <- data$shotDetailsV4Compressed$payload
  if (is.null(payload)) {
    cli_abort("No shot details returned for player {.val {player_id}}, round {round} in tournament {.val {tournament_id}}.")
  }

  parsed <- pga_decompress(payload)
  holes <- parsed$holes

  if (is.null(holes) || nrow(holes) == 0) {
    return(tibble())
  }

  all_strokes <- list()

  for (i in seq_len(nrow(holes))) {
    strokes_df <- holes$strokes[[i]]
    if (is.null(strokes_df) || !is.data.frame(strokes_df) || nrow(strokes_df) == 0) next

    # Extract the key columns, ignoring deeply nested coordinate data
    # Users can access raw coordinates via the overview columns if present
    stroke_rows <- tibble(
      hole_number = holes$holeNumber[i],
      par = holes$par[i],
      yardage = holes$yardage[i],
      hole_status = holes$status[i],
      hole_score = holes$score[i],
      stroke_number = strokes_df$strokeNumber,
      play_by_play = strokes_df$playByPlay,
      distance = strokes_df$distance,
      distance_remaining = strokes_df$distanceRemaining,
      stroke_type = strokes_df$strokeType,
      from_location = strokes_df$fromLocation %||% NA_character_,
      to_location = strokes_df$toLocation %||% NA_character_,
      from_location_code = strokes_df$fromLocationCode %||% NA_character_,
      to_location_code = strokes_df$toLocationCode %||% NA_character_,
      final_stroke = strokes_df$finalStroke %||% NA
    )

    # Add coordinate columns if available (flattened by fromJSON)
    coord_cols <- grep("^overview\\.", names(strokes_df), value = TRUE)
    if (length(coord_cols) > 0) {
      coord_data <- strokes_df[, coord_cols, drop = FALSE]
      names(coord_data) <- gsub("^overview\\.", "", names(coord_data))
      stroke_rows <- cbind(stroke_rows, coord_data)
      stroke_rows <- as_tibble(stroke_rows)
    }

    all_strokes[[length(all_strokes) + 1]] <- stroke_rows
  }

  if (length(all_strokes) == 0) {
    return(tibble())
  }

  do.call(rbind, all_strokes)
}
