#' Get broadcast/streaming coverage info
#'
#' Returns broadcast and streaming schedule for a tournament,
#' including networks, stream URLs, and time windows.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @return A tibble of coverage entries.
#' @export
#' @examples
#' \dontrun{
#' pga_coverage("R2026475")
#' }
pga_coverage <- function(tournament_id) {
  data <- pga_graphql_request(
    "Coverage",
    list(tournamentId = tournament_id)
  )

  coverage <- data$coverage
  if (is.null(coverage)) {
    cli_abort("No coverage data returned for tournament {.val {tournament_id}}.")
  }

  all_items <- coverage$coverageType
  if (is.null(all_items) || length(all_items) == 0) {
    return(tibble())
  }

  # Filter to items that have broadcast fields (skip Carousel, AudioStream, etc.)
  broadcast_types <- c("BroadcastFullTelecast", "BroadcastFeaturedGroup",
                        "BroadcastFeaturedHole")
  items <- Filter(function(x) x[["__typename"]] %in% broadcast_types, all_items)

  if (length(items) == 0) {
    return(tibble())
  }

  tibble(
    coverage_type = vapply(items, function(x) x[["__typename"]] %||% NA_character_, character(1)),
    id = vapply(items, function(x) x$id %||% NA_character_, character(1)),
    stream_title = vapply(items, function(x) x$streamTitle %||% NA_character_, character(1)),
    round_number = vapply(items, function(x) {
      as.integer(x$roundNumber %||% NA_integer_)
    }, integer(1)),
    start_time = as.POSIXct(
      vapply(items, function(x) x$startTime %||% NA_real_, double(1)) / 1000,
      origin = "1970-01-01", tz = "UTC"
    ),
    end_time = as.POSIXct(
      vapply(items, function(x) x$endTime %||% NA_real_, double(1)) / 1000,
      origin = "1970-01-01", tz = "UTC"
    ),
    live_status = vapply(items, function(x) x$liveStatus %||% NA_character_, character(1))
  )
}
