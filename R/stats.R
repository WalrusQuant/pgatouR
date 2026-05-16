#' Get PGA Tour statistics
#'
#' Returns player rankings for any of 300+ PGA Tour statistics.
#' See [stat_ids] for a full list of available stat IDs.
#'
#' The upstream `StatDetails` operation accepts a single `statId` and a single
#' `year` per request. When `stat_id` or `year` are passed as vectors, this
#' function loops internally and row-binds the results, adding `stat_id` and
#' `year` columns so chunks can be told apart.
#'
#' @param stat_id Character vector. One or more stat IDs (e.g., `"02675"` for
#'   SG: Total). When length > 1, results are stacked with a `stat_id` column.
#' @param year Integer vector or `NULL`. One or more season years. `NULL`
#'   (default) uses the current season. When length > 1, results are stacked
#'   with a `year` column.
#' @param tour Character. Tour code (`"R"`, `"S"`, or `"H"`). Defaults to `"R"`.
#' @param event_query Optional named list passed through as the GraphQL
#'   `StatDetailEventQuery` variable (e.g., for "Last 5 events" or FedEx Fall
#'   filters). Most callers can leave this `NULL`.
#' @return A tibble with one row per player per (stat_id, year) request.
#'   Includes rank, player info, and stat value columns. Multi-stat results
#'   are stacked vertically; columns absent for a given stat are filled with
#'   `NA`.
#' @export
#' @examples
#' \dontrun{
#' # Strokes Gained: Total, current season
#' pga_stats("02675")
#'
#' # Driving Distance, 2024 season
#' pga_stats("101", year = 2024)
#'
#' # Multiple stats in one call
#' pga_stats(c("02675", "101"))
#'
#' # Multi-year SG: Total
#' pga_stats("02675", year = 2022:2024)
#' }
pga_stats <- function(stat_id,
                      year = NULL,
                      tour = "R",
                      event_query = NULL) {
  validate_tour_code(tour)

  if (!is.character(stat_id) || length(stat_id) == 0 ||
      any(is.na(stat_id)) || any(!nzchar(stat_id))) {
    cli_abort("{.arg stat_id} must be a non-empty character vector with no NA or empty values.")
  }

  years <- if (is.null(year)) list(NULL) else as.list(as.integer(year))

  grid <- expand.grid(
    stat_id = stat_id,
    year_idx = seq_along(years),
    stringsAsFactors = FALSE,
    KEEP.OUT.ATTRS = FALSE
  )

  pieces <- vector("list", nrow(grid))
  for (i in seq_len(nrow(grid))) {
    sid <- grid$stat_id[i]
    yr <- years[[grid$year_idx[i]]]
    pieces[[i]] <- pga_stats_one(sid, yr, tour, event_query)
  }

  do.call(vec_rbind, pieces)
}

# Single (stat_id, year) request. Always returns a tibble (possibly zero-row)
# with stat_id and year columns prepended so binding across calls is safe.
pga_stats_one <- function(stat_id, year, tour, event_query) {
  variables <- list(tourCode = tour, statId = stat_id)
  if (!is.null(year)) variables$year <- as.integer(year)
  if (!is.null(event_query)) variables$eventQuery <- event_query

  data <- pga_graphql_request("StatDetails", variables)
  details <- data$statDetails
  if (is.null(details)) {
    cli_abort("No stat data returned for stat {.val {stat_id}}.")
  }

  rows <- details$rows
  resolved_year <- details$year %||% year %||% NA_integer_

  empty <- tibble(stat_id = character(), year = integer())
  if (is.null(rows) || length(rows) == 0) return(empty)

  is_player <- vapply(rows, function(r) {
    identical(r[["__typename"]], "StatDetailsPlayer")
  }, logical(1))
  player_rows <- rows[is_player]
  if (length(player_rows) == 0) return(empty)

  base <- tibble(
    stat_id = stat_id,
    year = as.integer(resolved_year),
    stat_title = details$statTitle %||% NA_character_,
    rank = vapply(player_rows, function(r) as.integer(r$rank %||% NA_integer_), integer(1)),
    rank_diff = vapply(player_rows, function(r) r$rankDiff %||% NA_character_, character(1)),
    rank_change_tendency = vapply(player_rows, function(r) r$rankChangeTendency %||% NA_character_, character(1)),
    player_id = vapply(player_rows, function(r) r$playerId %||% NA_character_, character(1)),
    player_name = vapply(player_rows, function(r) r$playerName %||% NA_character_, character(1)),
    country = vapply(player_rows, function(r) r$country %||% NA_character_, character(1)),
    country_flag = vapply(player_rows, function(r) r$countryFlag %||% NA_character_, character(1))
  )

  stat_headers <- details$statHeaders
  if (!is.null(stat_headers) && length(stat_headers) > 0) {
    stat_cols <- lapply(seq_along(stat_headers), function(i) {
      vapply(player_rows, function(r) {
        s <- r$stats
        if (is.null(s) || length(s) < i) return(NA_character_)
        s[[i]]$statValue %||% NA_character_
      }, character(1))
    })
    names(stat_cols) <- make_unique_snake(stat_headers)
    base <- vec_cbind(base, as_tibble(stat_cols))
  }

  base
}
