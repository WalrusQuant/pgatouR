#' Get tee times for a tournament
#'
#' Returns tee time groupings for each round of a tournament.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @return A tibble with one row per player per round, including tee time,
#'   starting tee, and group assignments.
#' @export
#' @examples
#' \dontrun{
#' pga_tee_times("R2026475")
#' }
pga_tee_times <- function(tournament_id) {
  data <- pga_graphql_request(
    "TeeTimesCompressedV2",
    list(teeTimesCompressedV2Id = tournament_id)
  )

  payload <- data$teeTimesCompressedV2$payload
  if (is.null(payload)) {
    cli_abort("No tee time data returned for tournament {.val {tournament_id}}.")
  }

  parsed <- pga_decompress(payload)
  rounds <- parsed$rounds

  if (is.null(rounds) || length(rounds) == 0) {
    return(tibble())
  }

  tz <- parsed$timezone %||% "America/New_York"

  all_rows <- list()

  for (r in seq_len(nrow(rounds))) {
    round_info <- rounds[r, ]
    round_num <- round_info$roundInt
    round_display <- round_info$roundDisplay
    round_status <- round_info$roundStatus
    groups <- round_info$groups

    if (is.null(groups) || length(groups) == 0) next

    # groups may be a list column
    if (is.data.frame(groups)) {
      grps <- groups
    } else if (is.list(groups) && length(groups) == 1) {
      grps <- groups[[1]]
    } else {
      next
    }

    for (g in seq_len(nrow(grps))) {
      group <- grps[g, ]
      players <- group$players

      if (is.null(players) || length(players) == 0) next

      if (is.data.frame(players)) {
        p_df <- players
      } else if (is.list(players) && length(players) == 1 && is.data.frame(players[[1]])) {
        p_df <- players[[1]]
      } else {
        next
      }

      tee_time_ms <- group$teeTime
      tee_time <- if (!is.null(tee_time_ms) && !is.na(tee_time_ms)) {
        as.POSIXct(tee_time_ms / 1000, origin = "1970-01-01", tz = tz)
      } else {
        as.POSIXct(NA)
      }

      for (p in seq_len(nrow(p_df))) {
        all_rows[[length(all_rows) + 1]] <- tibble(
          round_number = round_num,
          round_display = round_display,
          round_status = round_status,
          group_number = group$groupNumber,
          tee_time = tee_time,
          start_tee = group$startTee,
          back_nine = group$backNine %||% FALSE,
          player_id = p_df$id[p],
          first_name = p_df$firstName[p],
          last_name = p_df$lastName[p],
          display_name = p_df$displayName[p],
          country = p_df$country[p]
        )
      }
    }
  }

  if (length(all_rows) == 0) {
    return(tibble())
  }

  do.call(rbind, all_rows)
}
