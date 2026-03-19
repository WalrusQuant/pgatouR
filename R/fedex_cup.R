#' Get FedExCup standings
#'
#' Returns FedExCup standings with projected and official rankings.
#'
#' @param year Integer. Season year. Defaults to current year.
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble with player standings including rank, points, and movement.
#' @export
#' @examples
#' \dontrun{
#' pga_fedex_cup(2026)
#' }
pga_fedex_cup <- function(year = as.integer(format(Sys.Date(), "%Y")),
                          tour = "R") {
  validate_tour_code(tour)

  data <- pga_graphql_request(
    "TourCupSplit",
    list(tourCode = tour, id = "02671", year = as.integer(year))
  )

  cup <- data$tourCupSplit
  if (is.null(cup)) {
    cli_abort("No FedExCup data returned for {.val {year}}.")
  }

  # Use projected players if available, fall back to official
  players <- cup$projectedPlayers
  if (is.null(players) || length(players) == 0) {
    players <- cup$officialPlayers
  }

  if (is.null(players) || length(players) == 0) {
    return(tibble())
  }

  # Filter to actual player rows (not info rows)
  is_player <- vapply(players, function(p) {
    identical(p[["__typename"]], "TourCupCombinedPlayer")
  }, logical(1))

  player_rows <- players[is_player]

  if (length(player_rows) == 0) {
    return(tibble())
  }

  tibble(
    player_id = vapply(player_rows, function(p) p$id %||% NA_character_, character(1)),
    first_name = vapply(player_rows, function(p) p$firstName %||% NA_character_, character(1)),
    last_name = vapply(player_rows, function(p) p$lastName %||% NA_character_, character(1)),
    display_name = vapply(player_rows, function(p) p$displayName %||% NA_character_, character(1)),
    country = vapply(player_rows, function(p) p$country %||% NA_character_, character(1)),
    country_flag = vapply(player_rows, function(p) p$countryFlag %||% NA_character_, character(1)),
    this_week_rank = vapply(player_rows, function(p) p$thisWeekRank %||% NA_character_, character(1)),
    previous_week_rank = vapply(player_rows, function(p) p$previousWeekRank %||% NA_character_, character(1)),
    projected_rank = vapply(player_rows, function(p) safe_pluck(p, "rankingData", "projected") %||% NA_character_, character(1)),
    official_rank = vapply(player_rows, function(p) safe_pluck(p, "rankingData", "official") %||% NA_character_, character(1)),
    projected_points = vapply(player_rows, function(p) safe_pluck(p, "pointData", "projected") %||% NA_character_, character(1)),
    official_points = vapply(player_rows, function(p) safe_pluck(p, "pointData", "official") %||% NA_character_, character(1)),
    movement = vapply(player_rows, function(p) safe_pluck(p, "rankingData", "movement") %||% NA_character_, character(1)),
    movement_amount = vapply(player_rows, function(p) safe_pluck(p, "rankingData", "movementAmount") %||% NA_character_, character(1))
  )
}
