#' Get PGA Tour statistics
#'
#' Returns player rankings for any of 300+ PGA Tour statistics.
#' See [stat_ids] for a full list of available stat IDs.
#'
#' @param stat_id Character. Stat ID (e.g., `"02675"` for SG: Total).
#' @param year Integer or NULL. Season year. Defaults to current season.
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble with one row per player, including rank, player info,
#'   and stat values.
#' @export
#' @examples
#' \dontrun{
#' # Strokes Gained: Total
#' pga_stats("02675")
#'
#' # Driving Distance, 2024 season
#' pga_stats("101", year = 2024)
#' }
pga_stats <- function(stat_id, year = NULL, tour = "R") {
  validate_tour_code(tour)

  variables <- list(
    tourCode = tour,
    statId = stat_id
  )
  if (!is.null(year)) variables$year <- as.integer(year)

  data <- pga_graphql_request("StatDetails", variables)
  details <- data$statDetails

  if (is.null(details)) {
    cli_abort("No stat data returned for stat {.val {stat_id}}.")
  }

  rows <- details$rows
  if (is.null(rows) || length(rows) == 0) {
    return(tibble())
  }

  # Filter to player rows only (exclude tour averages)
  is_player <- vapply(rows, function(r) {
    identical(r[["__typename"]], "StatDetailsPlayer")
  }, logical(1))

  player_rows <- rows[is_player]

  if (length(player_rows) == 0) {
    return(tibble())
  }

  # Build base tibble
  result <- tibble(
    rank = vapply(player_rows, function(r) as.integer(r$rank %||% NA_integer_), integer(1)),
    rank_diff = vapply(player_rows, function(r) r$rankDiff %||% NA_character_, character(1)),
    rank_change_tendency = vapply(player_rows, function(r) r$rankChangeTendency %||% NA_character_, character(1)),
    player_id = vapply(player_rows, function(r) r$playerId %||% NA_character_, character(1)),
    player_name = vapply(player_rows, function(r) r$playerName %||% NA_character_, character(1)),
    country = vapply(player_rows, function(r) r$country %||% NA_character_, character(1)),
    country_flag = vapply(player_rows, function(r) r$countryFlag %||% NA_character_, character(1))
  )

  # Extract stat values as additional columns
  stat_headers <- details$statHeaders
  if (!is.null(stat_headers) && length(stat_headers) > 0) {
    stat_cols <- lapply(seq_along(stat_headers), function(i) {
      vapply(player_rows, function(r) {
        stats <- r$stats
        if (is.null(stats) || length(stats) < i) return(NA_character_)
        stats[[i]]$statValue %||% NA_character_
      }, character(1))
    })
    names(stat_cols) <- to_snake_case(stat_headers)
    result <- cbind(result, as.data.frame(stat_cols, stringsAsFactors = FALSE))
    result <- as_tibble(result)
  }

  # Attach metadata as attributes
  attr(result, "stat_title") <- details$statTitle
  attr(result, "stat_description") <- details$statDescription
  attr(result, "tour_avg") <- details$tourAvg
  attr(result, "year") <- details$year
  attr(result, "display_season") <- details$displaySeason

  result
}
