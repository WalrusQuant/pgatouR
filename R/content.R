#' Get CMS content fragment
#'
#' Wraps the `GenericContentCompressed` GraphQL operation. The response is a
#' decompressed JSON document whose shape varies by `path` — typically CMS
#' content blocks for editorial pages (overviews, hub pages, sponsor copy).
#' Returned as a nested list, not a tibble, because the schema isn't stable.
#'
#' @param path Character. CMS content path, e.g.
#'   `"/content/dam/pga-tour/fragments/pages/fedexcup/fedexcup-overview"`.
#' @return The decompressed JSON payload as a nested R list.
#' @export
#' @examples
#' \dontrun{
#' pga_content("/content/dam/pga-tour/fragments/pages/fedexcup/fedexcup-overview")
#' }
pga_content <- function(path) {
  if (!is.character(path) || length(path) != 1 || !nzchar(path)) {
    cli_abort("{.arg path} must be a non-empty character scalar.")
  }

  data <- pga_graphql_request("GenericContentCompressed", list(path = path))
  payload <- data$genericContentCompressed$payload
  if (is.null(payload)) {
    cli_abort("No content returned for path {.val {path}}.")
  }
  pga_decompress(payload)
}

#' Get odds interactivity configuration
#'
#' Returns the PGA Tour's odds-widget configuration (book partners, UI
#' settings). Returned as a nested list since the schema varies and is mostly
#' frontend wiring.
#'
#' @return The parsed JSON response as a nested R list.
#' @export
#' @examples
#' \dontrun{
#' pga_odds_interactivity()
#' }
pga_odds_interactivity <- function() {
  pga_rest_request("odds/interactivity")
}

#' Get speed-rounds video index
#'
#' Returns a list of speed-round videos for a given tour. Useful as a
#' content discovery surface; returned as a nested list because the entry
#' shapes are heterogeneous.
#'
#' @param tour Character. Tour code (`"R"`, `"S"`, `"H"`, or `"Y"`).
#'   Defaults to `"R"`.
#' @return The parsed JSON response as a nested R list.
#' @export
#' @examples
#' \dontrun{
#' pga_speed_rounds()
#' }
pga_speed_rounds <- function(tour = "R") {
  validate_tour_code(tour)
  pga_rest_request(paste0("content/watch/speedRounds/", tour))
}
