#' Get the tournament field
#'
#' Returns players (and optionally alternates) entered in a tournament,
#' including OWGR, withdrawn/alternate flags, and qualifier status.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026027"`).
#' @param include_withdrawn Logical. Include withdrawn players. Defaults to
#'   `TRUE`.
#' @return A tibble with one row per player. Alternates are included with
#'   `role = "alternate"`.
#' @export
#' @examples
#' \dontrun{
#' pga_field("R2026027")
#' }
pga_field <- function(tournament_id, include_withdrawn = TRUE) {
  data <- pga_graphql_request(
    "Field",
    list(
      fieldId = tournament_id,
      includeWithdrawn = include_withdrawn
    )
  )
  field <- data$field
  if (is.null(field)) {
    cli_abort("No field returned for tournament {.val {tournament_id}}.")
  }

  bind_field_players <- function(players, role) {
    if (is.null(players) || length(players) == 0) {
      return(NULL)
    }
    tibble(
      tournament_id = field$id %||% tournament_id,
      tournament_name = field$tournamentName %||% NA_character_,
      last_updated = field$lastUpdated %||% NA_character_,
      role = role,
      player_id = vapply(players, function(p) p$id %||% NA_character_, character(1)),
      first_name = vapply(players, function(p) p$firstName %||% NA_character_, character(1)),
      last_name = vapply(players, function(p) p$lastName %||% NA_character_, character(1)),
      display_name = vapply(players, function(p) p$displayName %||% NA_character_, character(1)),
      short_name = vapply(players, function(p) p$shortName %||% NA_character_, character(1)),
      country = vapply(players, function(p) p$country %||% NA_character_, character(1)),
      country_flag = vapply(players, function(p) p$countryFlag %||% NA_character_, character(1)),
      amateur = vapply(players, function(p) isTRUE(p$amateur), logical(1)),
      qualifier = vapply(players, function(p) isTRUE(p$qualifier), logical(1)),
      alternate = vapply(players, function(p) isTRUE(p$alternate), logical(1)),
      withdrawn = vapply(players, function(p) isTRUE(p$withdrawn), logical(1)),
      status = vapply(players, function(p) p$status %||% NA_character_, character(1)),
      owgr = vapply(players, function(p) p$owgr %||% NA_character_, character(1)),
      ranking_points = vapply(players, function(p) p$rankingPoints %||% NA_character_, character(1))
    )
  }

  pieces <- Filter(Negate(is.null), list(
    bind_field_players(field$players, "player"),
    bind_field_players(field$alternates, "alternate")
  ))
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}

#' Get field form / course-fit stats
#'
#' Wraps `FieldStats`. `stat_type` is an upstream `FieldStatType` value:
#' `"COURSE_FIT"` or `"CURRENT_FORM"`.
#'
#' @param tournament_id Character. Tournament ID.
#' @param stat_type Character. `"COURSE_FIT"` (default) or `"CURRENT_FORM"`.
#' @return A tibble with one row per player. Extra nested blocks (recent
#'   results, strokes-gained) are list-columns when present.
#' @export
#' @examples
#' \dontrun{
#' pga_field_stats("R2026027")
#' pga_field_stats("R2026027", "CURRENT_FORM")
#' }
pga_field_stats <- function(tournament_id, stat_type = "COURSE_FIT") {
  data <- pga_graphql_request(
    "FieldStats",
    list(tournamentId = tournament_id, fieldStatType = stat_type)
  )
  fs <- data$fieldStats
  if (is.null(fs)) {
    cli_abort("No field stats returned for tournament {.val {tournament_id}}.")
  }

  players <- fs$players
  if (is.null(players) || length(players) == 0) {
    return(tibble(
      tournament_id = character(),
      stat_type = character(),
      type_name = character(),
      player_id = character(),
      total_rounds = integer(),
      score = character(),
      stats = list(),
      tournament_results = list(),
      strokes_gained = list()
    ))
  }

  tibble(
    tournament_id = fs$tournamentId %||% tournament_id,
    stat_type = fs$fieldStatType %||% stat_type,
    type_name = vapply(players, function(p) p[["__typename"]] %||% NA_character_, character(1)),
    player_id = vapply(players, function(p) p$playerId %||% NA_character_, character(1)),
    total_rounds = vapply(players, function(p) as.integer(p$totalRounds %||% NA_integer_), integer(1)),
    score = vapply(players, function(p) p$score %||% NA_character_, character(1)),
    stats = lapply(players, function(p) p$stats),
    tournament_results = lapply(players, function(p) p$tournamentResults),
    strokes_gained = lapply(players, function(p) p$strokesGained)
  )
}
