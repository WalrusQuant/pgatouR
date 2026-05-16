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

  group_frames <- list()

  for (r in seq_len(nrow(rounds))) {
    round_info <- rounds[r, ]
    round_num <- round_info$roundInt
    round_display <- round_info$roundDisplay
    round_status <- round_info$roundStatus
    groups <- round_info$groups

    if (is.null(groups) || length(groups) == 0) next

    grps <- if (is.data.frame(groups)) {
      groups
    } else if (is.list(groups) && length(groups) == 1 && is.data.frame(groups[[1]])) {
      groups[[1]]
    } else {
      next
    }

    for (g in seq_len(nrow(grps))) {
      group <- grps[g, ]
      players <- group$players
      if (is.null(players) || length(players) == 0) next

      p_df <- if (is.data.frame(players)) {
        players
      } else if (is.list(players) && length(players) == 1 && is.data.frame(players[[1]])) {
        players[[1]]
      } else {
        next
      }
      n <- nrow(p_df)
      if (n == 0) next

      tee_time_ms <- group$teeTime
      tee_time <- if (!is.null(tee_time_ms) && !is.na(tee_time_ms)) {
        as.POSIXct(tee_time_ms / 1000, origin = "1970-01-01", tz = tz)
      } else {
        as.POSIXct(NA)
      }

      group_frames[[length(group_frames) + 1]] <- tibble(
        round_number = rep(round_num, n),
        round_display = rep(round_display, n),
        round_status = rep(round_status, n),
        group_number = rep(group$groupNumber, n),
        tee_time = rep(tee_time, n),
        start_tee = rep(group$startTee, n),
        back_nine = rep(group$backNine %||% FALSE, n),
        player_id = p_df$id %||% rep(NA_character_, n),
        first_name = p_df$firstName %||% rep(NA_character_, n),
        last_name = p_df$lastName %||% rep(NA_character_, n),
        display_name = p_df$displayName %||% rep(NA_character_, n),
        country = p_df$country %||% rep(NA_character_, n)
      )
    }
  }

  if (length(group_frames) == 0) return(tibble())
  do.call(vec_rbind, group_frames)
}
