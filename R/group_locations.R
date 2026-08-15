#' Get live group locations on the course
#'
#' Where each grouping is on the course for a given round.
#'
#' @param tournament_id Character. Tournament ID.
#' @param round Integer. Round number.
#' @return A tibble with one row per group-on-hole.
#' @export
#' @examples
#' \dontrun{
#' pga_group_locations("R2026027", round = 3)
#' }
pga_group_locations <- function(tournament_id, round) {
  data <- pga_graphql_request(
    "GroupLocations",
    list(tournamentId = tournament_id, round = as.integer(round))
  )
  gl <- data$groupLocations
  if (is.null(gl)) {
    cli_abort("No group locations returned for tournament {.val {tournament_id}}.")
  }

  pieces <- list()
  for (course in gl$courses %||% list()) {
    for (hole in course$holes %||% list()) {
      for (g in hole$groups %||% list()) {
        pd <- g$playerData
        pieces[[length(pieces) + 1]] <- tibble(
          tournament_id = course$tournamentId %||% gl$tournamentId %||% tournament_id,
          course_id = course$courseId %||% NA_character_,
          course_name = course$courseName %||% NA_character_,
          round_number = as.integer(course$round %||% g$round %||% round),
          hole_number = as.integer(hole$holeNumber %||% NA_integer_),
          par = as.integer(hole$par %||% NA_integer_),
          yardage = as.integer(hole$yardage %||% NA_integer_),
          group_number = as.integer(g$groupNum %||% NA_integer_),
          location = g$location %||% NA_character_,
          color = g$color %||% NA_character_,
          addressing_ball = isTRUE(safe_pluck(pd, "addressingBall")),
          next_to_hit = isTRUE(safe_pluck(pd, "nextToHit"))
        )
      }
    }
  }
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}
