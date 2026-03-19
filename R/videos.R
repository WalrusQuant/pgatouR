#' Get player video highlights
#'
#' Returns video content with optional filtering by player, tournament,
#' and franchise categories.
#'
#' @param player_ids Character vector or NULL. Player IDs to filter by.
#' @param tournament_id Character or NULL. Tournament ID (numeric part only, e.g., `"475"`).
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @param season Character or NULL. Season year as string (e.g., `"2026"`).
#' @param franchises Character vector or NULL. Franchise filters
#'   (e.g., `"competition#highlights"`).
#' @param limit Integer. Max videos. Defaults to 18.
#' @param offset Integer. Pagination offset. Defaults to 0.
#' @return A tibble of videos.
#' @export
#' @examples
#' \dontrun{
#' pga_videos(player_ids = "39971", tournament_id = "475")
#' }
pga_videos <- function(player_ids = NULL, tournament_id = NULL, tour = "R",
                       season = NULL, franchises = NULL,
                       limit = 18L, offset = 0L) {
  variables <- list(
    tourCode = tour,
    limit = as.integer(limit),
    offset = as.integer(offset)
  )
  if (!is.null(player_ids)) variables$playerIds <- as.list(player_ids)
  if (!is.null(tournament_id)) variables$tournamentId <- tournament_id
  if (!is.null(season)) variables$season <- season
  if (!is.null(franchises)) variables$franchises <- as.list(franchises)

  data <- pga_graphql_request("Videos", variables)
  videos <- data$videos

  if (is.null(videos) || length(videos) == 0) {
    return(tibble())
  }

  tibble(
    id = vapply(videos, function(v) v$id %||% NA_character_, character(1)),
    title = vapply(videos, function(v) v$title %||% NA_character_, character(1)),
    description = vapply(videos, function(v) v$description %||% NA_character_, character(1)),
    duration_secs = vapply(videos, function(v) as.integer(v$duration %||% NA_integer_), integer(1)),
    category = vapply(videos, function(v) v$category %||% NA_character_, character(1)),
    category_display_name = vapply(videos, function(v) v$categoryDisplayName %||% NA_character_, character(1)),
    franchise = vapply(videos, function(v) v$franchise %||% NA_character_, character(1)),
    franchise_display_name = vapply(videos, function(v) v$franchiseDisplayName %||% NA_character_, character(1)),
    hole_number = vapply(videos, function(v) v$holeNumber %||% NA_character_, character(1)),
    round_number = vapply(videos, function(v) v$roundNumber %||% NA_character_, character(1)),
    shot_number = vapply(videos, function(v) v$shotNumber %||% NA_character_, character(1)),
    share_url = vapply(videos, function(v) v$shareUrl %||% NA_character_, character(1)),
    thumbnail = vapply(videos, function(v) v$thumbnail %||% NA_character_, character(1)),
    pub_date = as.POSIXct(
      vapply(videos, function(v) v$pubdate %||% NA_real_, double(1)) / 1000,
      origin = "1970-01-01", tz = "UTC"
    ),
    tournament_id = vapply(videos, function(v) v$tournamentId %||% NA_character_, character(1)),
    tour_code = vapply(videos, function(v) v$tourCode %||% NA_character_, character(1)),
    year = vapply(videos, function(v) v$year %||% NA_character_, character(1))
  )
}

#' Get shot-by-shot video clips for a player round
#'
#' Returns video clips for individual shots in a player's round.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @param player_id Character. Player ID.
#' @param round Integer. Round number.
#' @param hole Integer or NULL. Specific hole number.
#' @param shot Integer or NULL. Specific shot number.
#' @return A tibble of video clips.
#' @export
#' @examples
#' \dontrun{
#' pga_tourcast_videos("R2026475", "39971", round = 1)
#' }
pga_tourcast_videos <- function(tournament_id, player_id, round,
                                hole = NULL, shot = NULL) {
  variables <- list(
    tournamentId = tournament_id,
    playerId = player_id,
    round = as.integer(round)
  )
  if (!is.null(hole)) variables$hole <- as.integer(hole)
  if (!is.null(shot)) variables$shot <- as.integer(shot)

  data <- pga_graphql_request("TourcastVideos", variables)
  videos <- data$tourcastVideos

  if (is.null(videos) || length(videos) == 0) {
    return(tibble())
  }

  tibble(
    id = vapply(videos, function(v) v$id %||% NA_character_, character(1)),
    title = vapply(videos, function(v) v$title %||% NA_character_, character(1)),
    description = vapply(videos, function(v) v$description %||% NA_character_, character(1)),
    duration_secs = vapply(videos, function(v) as.integer(v$duration %||% NA_integer_), integer(1)),
    hole_number = vapply(videos, function(v) v$holeNumber %||% NA_character_, character(1)),
    round_number = vapply(videos, function(v) v$roundNumber %||% NA_character_, character(1)),
    shot_number = vapply(videos, function(v) v$shotNumber %||% NA_character_, character(1)),
    share_url = vapply(videos, function(v) v$shareUrl %||% NA_character_, character(1)),
    thumbnail = vapply(videos, function(v) v$thumbnail %||% NA_character_, character(1)),
    starts_at = as.POSIXct(
      vapply(videos, function(v) v$startsAt %||% NA_real_, double(1)) / 1000,
      origin = "1970-01-01", tz = "UTC"
    ),
    ends_at = as.POSIXct(
      vapply(videos, function(v) v$endsAt %||% NA_real_, double(1)) / 1000,
      origin = "1970-01-01", tz = "UTC"
    ),
    tournament_id = vapply(videos, function(v) v$tournamentId %||% NA_character_, character(1)),
    tour_code = vapply(videos, function(v) v$tourCode %||% NA_character_, character(1))
  )
}
