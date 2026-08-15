#' Get hole-level course stats for a tournament
#'
#' Scoring averages, birdie/bogey counts, and rank for each hole, by round.
#'
#' @param tournament_id Character. Tournament ID.
#' @return A tibble with one row per course-round-hole. Summary rows (front
#'   nine / back nine / total) are included with `is_summary = TRUE`.
#' @export
#' @examples
#' \dontrun{
#' pga_course_stats("R2026027")
#' }
pga_course_stats <- function(tournament_id) {
  data <- pga_graphql_request("CourseStats", list(tournamentId = tournament_id))
  cs <- data$courseStats
  if (is.null(cs)) {
    cli_abort("No course stats returned for tournament {.val {tournament_id}}.")
  }

  courses <- cs$courses
  if (is.null(courses) || length(courses) == 0) {
    return(tibble())
  }

  pieces <- list()
  for (course in courses) {
    for (rnd in course$roundHoleStats %||% list()) {
      for (hole in rnd$holeStats %||% list()) {
        is_summary <- identical(hole[["__typename"]], "SummaryRow")
        pieces[[length(pieces) + 1]] <- tibble(
          tournament_id = course$tournamentId %||% cs$tournamentId %||% tournament_id,
          course_id = course$courseId %||% NA_character_,
          course_name = course$courseName %||% NA_character_,
          course_code = course$courseCode %||% NA_character_,
          host_course = isTRUE(course$hostCourse),
          round_number = as.integer(rnd$roundNum %||% NA_integer_),
          round_header = rnd$roundHeader %||% NA_character_,
          live = isTRUE(rnd$live) || isTRUE(hole$live),
          is_summary = is_summary,
          hole_number = as.integer(hole$courseHoleNum %||% NA_integer_),
          row_type = hole$rowType %||% NA_character_,
          par = as.integer(hole$parValue %||% hole$par %||% NA_integer_),
          yards = as.integer(hole$yards %||% hole$yardage %||% NA_integer_),
          scoring_average = hole$scoringAverage %||% NA_character_,
          scoring_average_diff = hole$scoringAverageDiff %||% NA_character_,
          scoring_diff_tendency = hole$scoringDiffTendency %||% NA_character_,
          eagles = as_chr(hole$eagles),
          birdies = as_chr(hole$birdies),
          pars = as_chr(hole$pars),
          bogeys = as_chr(hole$bogeys),
          double_bogey = as_chr(hole$doubleBogey),
          rank = as_chr(hole$rank)
        )
      }
    }
  }

  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}

#' Get the season course-stats hub
#'
#' Category cards from `/stats/course` (hardest/easiest holes, etc.).
#'
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @param year Integer or `NULL`. Season year. `NULL` uses the current season.
#' @return A tibble with one row per ranked item.
#' @export
pga_course_stats_overview <- function(tour = "R", year = NULL) {
  validate_tour_code(tour)
  variables <- list(tourCode = tour)
  if (!is.null(year)) variables$year <- as.integer(year)

  data <- pga_graphql_request("CourseStatsOverview", variables)
  ov <- data$courseStatsOverview
  if (is.null(ov)) {
    cli_abort("No course-stats overview returned for tour {.val {tour}}.")
  }

  pieces <- list()
  for (cat in ov$categories %||% list()) {
    for (item in cat$items %||% list()) {
      details <- item$details %||% list()
      pieces[[length(pieces) + 1]] <- tibble(
        tour = ov$tourCode %||% tour,
        year = as.integer(ov$year %||% year %||% NA_integer_),
        category = cat$header %||% NA_character_,
        detail_id = cat$detailId %||% NA_character_,
        display_name = item$displayName %||% NA_character_,
        rank = item$rank %||% NA_character_,
        image = item$image %||% NA_character_,
        detail_label = vapply(details, function(d) d$label %||% NA_character_, character(1)),
        detail_value = vapply(details, function(d) d$value %||% NA_character_, character(1))
      )
    }
  }
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}

#' Get details for a single hole
#'
#' Scoring breakdown plus groups currently on the hole.
#'
#' @param tournament_id Character. Tournament ID.
#' @param course_id Character. Course ID (from [pga_tournaments()] or
#'   [pga_course_stats()]).
#' @param hole Integer. Hole number (1-18).
#' @return A named list with hole metadata, `stats` (a one-row tibble), and
#'   `groups` (players on the hole by round).
#' @export
pga_hole_details <- function(tournament_id, course_id, hole) {
  data <- pga_graphql_request(
    "HoleDetails",
    list(
      tournamentId = tournament_id,
      courseId = as.character(course_id),
      hole = as.integer(hole)
    )
  )
  hd <- data$holeDetails
  if (is.null(hd)) {
    cli_abort("No hole details returned for hole {hole} at course {.val {course_id}}.")
  }

  summary <- hd$statsSummary
  stats <- if (is.null(summary)) {
    tibble()
  } else {
    tibble(
      tournament_id = summary$tournamentId %||% tournament_id,
      course_id = summary$courseId %||% as.character(course_id),
      hole_number = as.integer(summary$holeNum %||% hole),
      eagles = summary$eagles %||% NA_character_,
      eagles_pct = summary$eaglesPercent %||% NA_character_,
      birdies = summary$birdies %||% NA_character_,
      birdies_pct = summary$birdiesPercent %||% NA_character_,
      pars = summary$pars %||% NA_character_,
      pars_pct = summary$parsPercent %||% NA_character_,
      bogeys = summary$bogeys %||% NA_character_,
      bogeys_pct = summary$bogeysPercent %||% NA_character_,
      double_bogeys = summary$doubleBogeys %||% NA_character_,
      double_bogeys_pct = summary$doubleBogeysPercent %||% NA_character_
    )
  }

  info <- hd$holeInfo
  groups <- hole_groups_tbl(hd$rounds)

  list(
    tournament_id = hd$tournamentId %||% tournament_id,
    course_id = hd$courseId %||% as.character(course_id),
    hole_number = as.integer(hd$holeNum %||% hole),
    par = as.integer(safe_pluck(info, "par") %||% NA_integer_),
    yards = as.integer(safe_pluck(info, "yards") %||% NA_integer_),
    rank = safe_pluck(info, "rank") %||% NA_character_,
    about = safe_pluck(info, "aboutThisHole") %||% NA_character_,
    hole_image = hd$holeImage %||% NA_character_,
    tourcast_url = hd$tourcastURL %||% hd$tourcastURLWeb %||% NA_character_,
    stats = stats,
    groups = groups
  )
}

hole_groups_tbl <- function(rounds) {
  if (is.null(rounds) || length(rounds) == 0) {
    return(tibble())
  }
  pieces <- list()
  for (rnd in rounds) {
    for (g in rnd$groups %||% list()) {
      players <- g$players %||% list()
      if (length(players) == 0) next
      pieces[[length(pieces) + 1]] <- tibble(
        round_number = as.integer(rnd$roundNum %||% NA_integer_),
        group_number = as.integer(g$groupNumber %||% NA_integer_),
        location = g$groupLocation %||% NA_character_,
        location_code = g$groupLocationCode %||% NA_character_,
        player_id = vapply(players, function(p) p$playerId %||% NA_character_, character(1)),
        first_name = vapply(players, function(p) p$firstName %||% NA_character_, character(1)),
        last_name = vapply(players, function(p) p$lastName %||% NA_character_, character(1)),
        country = vapply(players, function(p) p$country %||% NA_character_, character(1)),
        position = vapply(players, function(p) p$position %||% NA_character_, character(1)),
        total = vapply(players, function(p) p$total %||% NA_character_, character(1)),
        round_score = vapply(players, function(p) p$roundScore %||% NA_character_, character(1))
      )
    }
  }
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}
