#' Get PGA Tour player directory
#'
#' Returns the full player directory for a tour.
#'
#' @param tour Character. Tour code: `"R"` (PGA Tour), `"S"` (Champions),
#'   `"H"` (Korn Ferry). Defaults to `"R"`.
#' @return A tibble with one row per player.
#' @export
#' @examples
#' \dontrun{
#' pga_players()
#' pga_players("H")
#' }
pga_players <- function(tour = "R") {
  validate_tour_code(tour)

  resp <- pga_rest_request(paste0("player/list/", tour))
  data <- resp$players

  if (is.null(data) || length(data) == 0) {
    return(tibble())
  }

  tibble(
    player_id = vapply(data, function(x) x$id %||% NA_character_, character(1)),
    tour_code = vapply(data, function(x) x$tourCode %||% NA_character_, character(1)),
    is_primary = vapply(data, function(x) x$isPrimary %||% NA, logical(1)),
    is_active = vapply(data, function(x) x$isActive %||% NA, logical(1)),
    first_name = vapply(data, function(x) x$firstName %||% NA_character_, character(1)),
    last_name = vapply(data, function(x) x$lastName %||% NA_character_, character(1)),
    display_name = vapply(data, function(x) x$displayName %||% NA_character_, character(1)),
    short_name = vapply(data, function(x) x$shortName %||% NA_character_, character(1)),
    country = vapply(data, function(x) x$country %||% NA_character_, character(1)),
    country_flag = vapply(data, function(x) x$countryFlag %||% NA_character_, character(1)),
    age = vapply(data, function(x) safe_pluck(x, "playerBio", "age") %||% NA_character_, character(1)),
    primary_tour = vapply(data, function(x) x$primaryTour %||% NA_character_, character(1))
  )
}

#' Null-coalescing operator
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
