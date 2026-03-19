#' Get tournament metadata
#'
#' Returns tournament details including name, location, courses, weather,
#' status, and format.
#'
#' @param ids Character vector. One or more tournament IDs (e.g., `"R2026475"`).
#' @return A tibble with one row per tournament.
#' @export
#' @examples
#' \dontrun{
#' pga_tournaments("R2026475")
#' pga_tournaments(c("R2026475", "R2026003"))
#' }
pga_tournaments <- function(ids) {
  if (!is.character(ids)) {
    cli_abort("{.arg ids} must be a character vector of tournament IDs.")
  }

  data <- pga_graphql_request(
    "Tournaments",
    list(ids = as.list(ids))
  )

  tournaments <- data$tournaments
  if (is.null(tournaments) || length(tournaments) == 0) {
    return(tibble())
  }

  tibble(
    id = vapply(tournaments, function(t) t$id %||% NA_character_, character(1)),
    tournament_name = vapply(tournaments, function(t) t$tournamentName %||% NA_character_, character(1)),
    tournament_status = vapply(tournaments, function(t) t$tournamentStatus %||% NA_character_, character(1)),
    display_date = vapply(tournaments, function(t) t$displayDate %||% NA_character_, character(1)),
    season_year = vapply(tournaments, function(t) t$seasonYear %||% NA_character_, character(1)),
    country = vapply(tournaments, function(t) t$country %||% NA_character_, character(1)),
    state = vapply(tournaments, function(t) t$state %||% NA_character_, character(1)),
    city = vapply(tournaments, function(t) t$city %||% NA_character_, character(1)),
    timezone = vapply(tournaments, function(t) t$timezone %||% NA_character_, character(1)),
    format_type = vapply(tournaments, function(t) t$formatType %||% NA_character_, character(1)),
    current_round = vapply(tournaments, function(t) {
      as.integer(t$currentRound %||% NA_integer_)
    }, integer(1)),
    round_status = vapply(tournaments, function(t) t$roundStatus %||% NA_character_, character(1)),
    round_display = vapply(tournaments, function(t) t$roundDisplay %||% NA_character_, character(1)),
    round_status_display = vapply(tournaments, function(t) t$roundStatusDisplay %||% NA_character_, character(1)),
    scored_level = vapply(tournaments, function(t) t$scoredLevel %||% NA_character_, character(1)),
    tournament_site_url = vapply(tournaments, function(t) t$tournamentSiteURL %||% NA_character_, character(1)),
    beauty_image = vapply(tournaments, function(t) t$beautyImage %||% NA_character_, character(1)),
    headshot_base_url = vapply(tournaments, function(t) t$headshotBaseUrl %||% NA_character_, character(1)),
    # Weather as nested columns
    weather_temp_f = vapply(tournaments, function(t) safe_pluck(t, "weather", "tempF") %||% NA_character_, character(1)),
    weather_temp_c = vapply(tournaments, function(t) safe_pluck(t, "weather", "tempC") %||% NA_character_, character(1)),
    weather_condition = vapply(tournaments, function(t) safe_pluck(t, "weather", "condition") %||% NA_character_, character(1)),
    weather_wind_mph = vapply(tournaments, function(t) safe_pluck(t, "weather", "windSpeedMPH") %||% NA_character_, character(1)),
    weather_humidity = vapply(tournaments, function(t) safe_pluck(t, "weather", "humidity") %||% NA_character_, character(1)),
    # Courses as list column
    courses = lapply(tournaments, function(t) {
      c_data <- t$courses
      if (is.null(c_data)) return(tibble())
      tryCatch(as_tibble(do.call(rbind, lapply(c_data, as.data.frame, stringsAsFactors = FALSE))),
               error = function(e) tibble())
    })
  )
}
