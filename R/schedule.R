#' Get season schedule
#'
#' Returns the full tournament schedule for a season including dates,
#' status, purse, course, champion, and FedExCup points.
#'
#' @param year Integer. Season year. Defaults to current year.
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble with one row per tournament.
#' @export
#' @examples
#' \dontrun{
#' # Current season
#' pga_schedule(2026)
#'
#' # Past season
#' pga_schedule(2025)
#' }
pga_schedule <- function(year = as.integer(format(Sys.Date(), "%Y")),
                         tour = "R") {
  validate_tour_code(tour)

  resp <- pga_rest_request(paste0("schedule/", tour, "/", year))
  tournaments <- resp$tournaments

  if (is.null(tournaments) || length(tournaments) == 0) {
    return(tibble())
  }

  tibble(
    tournament_id = vapply(tournaments, function(t) t$tournamentId %||% NA_character_, character(1)),
    tournament_name = vapply(tournaments, function(t) t$name %||% NA_character_, character(1)),
    year = vapply(tournaments, function(t) t$year %||% NA_character_, character(1)),
    month = vapply(tournaments, function(t) t$month %||% NA_character_, character(1)),
    display_date = vapply(tournaments, function(t) t$displayDate %||% NA_character_, character(1)),
    status = vapply(tournaments, function(t) t$status %||% NA_character_, character(1)),
    purse = vapply(tournaments, function(t) t$purse %||% NA_character_, character(1)),
    fedex_cup_points = vapply(tournaments, function(t) {
      safe_pluck(t, "standings", "value") %||% NA_character_
    }, character(1)),
    champion = vapply(tournaments, function(t) {
      champs <- t$champions
      if (is.null(champs) || length(champs) == 0) return(NA_character_)
      champs[[1]]$displayName %||% NA_character_
    }, character(1)),
    champion_earnings = vapply(tournaments, function(t) t$championEarnings %||% NA_character_, character(1)),
    course_name = vapply(tournaments, function(t) {
      safe_pluck(t, "courseData", "name") %||% NA_character_
    }, character(1)),
    city = vapply(tournaments, function(t) {
      safe_pluck(t, "courseData", "city") %||% NA_character_
    }, character(1)),
    state = vapply(tournaments, function(t) {
      safe_pluck(t, "courseData", "stateCode") %||% NA_character_
    }, character(1)),
    country = vapply(tournaments, function(t) {
      safe_pluck(t, "courseData", "country") %||% NA_character_
    }, character(1)),
    tournament_site_url = vapply(tournaments, function(t) t$tournamentSiteUrl %||% NA_character_, character(1))
  )
}
