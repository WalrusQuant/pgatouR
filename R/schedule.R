#' Get season schedule
#'
#' Returns the tournament schedule for a season, pulled from the FedExCup
#' standings tournament pills. For in-progress seasons, only tournaments
#' played so far will be listed. For completed seasons, the full schedule
#' is returned.
#'
#' @param year Integer. Season year. Defaults to current year.
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble with `tournament_id` and `tournament_name` columns,
#'   ordered from most recent to earliest in the season.
#' @export
#' @examples
#' \dontrun{
#' # Current season (in-progress, shows completed events)
#' pga_schedule(2026)
#'
#' # Full past season
#' pga_schedule(2025)
#' }
pga_schedule <- function(year = as.integer(format(Sys.Date(), "%Y")),
                         tour = "R") {
  validate_tour_code(tour)

  data <- pga_graphql_request(
    "TourCupSplit",
    list(tourCode = tour, id = "02671", year = as.integer(year))
  )

  cup <- data$tourCupSplit
  if (is.null(cup)) {
    cli_abort("No schedule data returned for {.val {year}}.")
  }

  pills <- cup$tournamentPills
  if (is.null(pills) || length(pills) == 0) {
    return(tibble())
  }

  tibble(
    tournament_id = vapply(pills, function(p) p$tournamentId %||% NA_character_, character(1)),
    tournament_name = vapply(pills, function(p) p$displayName %||% NA_character_, character(1))
  )
}
