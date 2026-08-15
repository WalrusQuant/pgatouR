#' Get the tour's current / featured tournament
#'
#' Reads the PGA Tour web-config default tournament for a tour — the same
#' source the live site uses for "this week."
#'
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble with one row per featured event (`tournament_id`,
#'   `leaderboard_id`). Empty when the config has no default for that tour.
#' @export
#' @examples
#' \dontrun{
#' pga_current_tournament()
#' pga_current_tournament("Y")
#' }
pga_current_tournament <- function(tour = "R") {
  validate_tour_code(tour)
  cfg <- pga_config_request("web-config")
  defaults <- safe_pluck(cfg, "defaultTournaments", tour)
  if (is.null(defaults) || length(defaults) == 0) {
    return(tibble())
  }

  tibble(
    tour = tour,
    tournament_id = vapply(defaults, function(d) d$id %||% NA_character_, character(1)),
    leaderboard_id = vapply(defaults, function(d) {
      d$leaderboardId %||% d$id %||% NA_character_
    }, character(1))
  )
}

#' Get tournament overview
#'
#' Returns overview copy, defending/past champions, and course blurbs
#' for a tournament's hub page.
#'
#' @param tournament_id Character. Tournament ID.
#' @return A named list with `tournament_id`, `format_type`, URL fields,
#'   plus tibbles `overview`, `champions`, and `courses`.
#' @export
#' @examples
#' \dontrun{
#' pga_tournament_overview("R2026027")
#' }
pga_tournament_overview <- function(tournament_id) {
  data <- pga_graphql_request(
    "TournamentOverview",
    list(tournamentId = tournament_id)
  )
  ov <- data$tournamentOverview
  if (is.null(ov)) {
    cli_abort("No overview returned for tournament {.val {tournament_id}}.")
  }

  list(
    tournament_id = tournament_id,
    format_type = ov$formatType %||% NA_character_,
    tickets_url = ov$ticketsURL %||% NA_character_,
    tourcast_url = ov$tourcastURL %||% ov$tourcastURLWeb %||% NA_character_,
    share_url = ov$shareURL %||% NA_character_,
    event_guide_url = ov$eventGuideURL %||% NA_character_,
    beauty_image = ov$beautyImage %||% NA_character_,
    overview = overview_items_tbl(ov$overview),
    champions = champions_tbl(c(list(ov$defendingChampion), ov$pastChampions %||% list())),
    courses = overview_courses_tbl(ov$courses)
  )
}

#' Get historical results for a tournament
#'
#' Returns the full field result list for a prior playing of an event.
#' `tournament_id` is the current-season ID (e.g. `"R2026027"`); `year`
#' selects which edition.
#'
#' @param tournament_id Character. Tournament ID.
#' @param year Integer or `NULL`. Season to return. `NULL` uses the latest
#'   available season in the response.
#' @return A tibble with one row per player, plus round-score columns.
#' @export
#' @examples
#' \dontrun{
#' pga_tournament_past_results("R2026027", year = 2025)
#' }
pga_tournament_past_results <- function(tournament_id, year = NULL) {
  variables <- list(tournamentPastResultsId = tournament_id)
  if (!is.null(year)) variables$year <- as.integer(year)

  data <- pga_graphql_request("TournamentPastResults", variables)
  res <- data$tournamentPastResults
  if (is.null(res)) {
    cli_abort("No past results returned for tournament {.val {tournament_id}}.")
  }

  players <- res$players
  if (is.null(players) || length(players) == 0) {
    return(tibble())
  }

  n_rounds <- if (is.null(res$rounds)) {
    0L
  } else if (length(res$rounds) == 1L && is.numeric(res$rounds)) {
    as.integer(res$rounds)
  } else {
    length(res$rounds)
  }

  extra_headers <- res$additionalDataHeaders %||% character()

  base <- tibble(
    tournament_id = res$id %||% tournament_id,
    player_id = vapply(players, function(p) {
      safe_pluck(p, "player", "id") %||% p$id %||% NA_character_
    }, character(1)),
    first_name = vapply(players, function(p) safe_pluck(p, "player", "firstName") %||% NA_character_, character(1)),
    last_name = vapply(players, function(p) safe_pluck(p, "player", "lastName") %||% NA_character_, character(1)),
    display_name = vapply(players, function(p) safe_pluck(p, "player", "displayName") %||% NA_character_, character(1)),
    country = vapply(players, function(p) safe_pluck(p, "player", "country") %||% NA_character_, character(1)),
    country_flag = vapply(players, function(p) safe_pluck(p, "player", "countryFlag") %||% NA_character_, character(1)),
    amateur = vapply(players, function(p) isTRUE(safe_pluck(p, "player", "amateur")), logical(1)),
    position = vapply(players, function(p) p$position %||% NA_character_, character(1)),
    total = vapply(players, function(p) p$total %||% NA_character_, character(1)),
    to_par = vapply(players, function(p) p$parRelativeScore %||% NA_character_, character(1))
  )

  if (n_rounds > 0) {
    round_cols <- lapply(seq_len(n_rounds), function(i) {
      vapply(players, function(p) {
        rnds <- p$rounds
        if (is.null(rnds) || length(rnds) < i) return(NA_character_)
        rnds[[i]]$score %||% NA_character_
      }, character(1))
    })
    names(round_cols) <- paste0("round_", seq_len(n_rounds))
    base <- vec_cbind(base, as_tibble(round_cols))
  }

  if (length(extra_headers) > 0) {
    extra_cols <- lapply(seq_along(extra_headers), function(i) {
      vapply(players, function(p) {
        extra <- p$additionalData
        if (is.null(extra) || length(extra) < i) return(NA_character_)
        extra[[i]] %||% NA_character_
      }, character(1))
    })
    names(extra_cols) <- make_unique_snake(extra_headers)
    base <- vec_cbind(base, as_tibble(extra_cols))
  }

  base
}

#' Get tournament weather forecast
#'
#' Hourly and daily forecasts for a tournament site.
#'
#' @param tournament_id Character. Tournament ID.
#' @return A tibble with one row per forecast period (`scope` is
#'   `"hourly"` or `"daily"`).
#' @export
#' @examples
#' \dontrun{
#' pga_weather("R2026027")
#' }
pga_weather <- function(tournament_id) {
  data <- pga_graphql_request("Weather", list(tournamentId = tournament_id))
  wx <- data$weather
  if (is.null(wx)) {
    cli_abort("No weather returned for tournament {.val {tournament_id}}.")
  }

  pieces <- Filter(Negate(is.null), list(
    weather_rows(wx$hourly, "hourly"),
    weather_rows(wx$daily, "daily")
  ))
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}

overview_items_tbl <- function(items) {
  if (is.null(items) || length(items) == 0) {
    return(tibble())
  }
  tibble(
    label = vapply(items, function(x) x$label %||% NA_character_, character(1)),
    value = vapply(items, function(x) x$value %||% NA_character_, character(1)),
    detail = vapply(items, function(x) x$detail %||% NA_character_, character(1)),
    secondary_detail = vapply(items, function(x) x$secondaryDetail %||% NA_character_, character(1))
  )
}

champions_tbl <- function(rows) {
  rows <- Filter(function(x) !is.null(x) && length(x) > 0, rows)
  if (length(rows) == 0) {
    return(tibble())
  }
  tibble(
    player_id = vapply(rows, function(x) x$playerId %||% NA_character_, character(1)),
    display_name = vapply(rows, function(x) x$displayName %||% NA_character_, character(1)),
    year = vapply(rows, function(x) as_chr(x$year %||% x$displaySeason), character(1)),
    score = vapply(rows, function(x) x$score %||% NA_character_, character(1)),
    total = vapply(rows, function(x) x$total %||% NA_character_, character(1)),
    title = vapply(rows, function(x) x$title %||% NA_character_, character(1)),
    country_code = vapply(rows, function(x) x$countryCode %||% NA_character_, character(1))
  )
}

overview_courses_tbl <- function(courses) {
  if (is.null(courses) || length(courses) == 0) {
    return(tibble())
  }
  tibble(
    course_id = vapply(courses, function(c) c$id %||% NA_character_, character(1)),
    name = vapply(courses, function(c) c$name %||% NA_character_, character(1)),
    city = vapply(courses, function(c) c$city %||% NA_character_, character(1)),
    state = vapply(courses, function(c) c$state %||% NA_character_, character(1)),
    country = vapply(courses, function(c) c$country %||% NA_character_, character(1)),
    image = vapply(courses, function(c) c$image %||% NA_character_, character(1)),
    overview = lapply(courses, function(c) overview_items_tbl(c$overview))
  )
}

weather_rows <- function(periods, scope) {
  if (is.null(periods) || length(periods) == 0) {
    return(NULL)
  }
  temps <- lapply(periods, function(p) weather_temp(p$temperature))
  tibble(
    scope = scope,
    title = vapply(periods, function(p) p$title %||% NA_character_, character(1)),
    condition = vapply(periods, function(p) p$condition %||% NA_character_, character(1)),
    wind_direction = vapply(periods, function(p) p$windDirection %||% NA_character_, character(1)),
    wind_mph = vapply(periods, function(p) p$windSpeedMPH %||% NA_character_, character(1)),
    wind_kph = vapply(periods, function(p) p$windSpeedKPH %||% NA_character_, character(1)),
    humidity = vapply(periods, function(p) p$humidity %||% NA_character_, character(1)),
    precipitation = vapply(periods, function(p) p$precipitation %||% NA_character_, character(1)),
    temp_f = vapply(temps, function(t) t$temp_f, character(1)),
    temp_c = vapply(temps, function(t) t$temp_c, character(1)),
    min_temp_f = vapply(temps, function(t) t$min_f, character(1)),
    min_temp_c = vapply(temps, function(t) t$min_c, character(1)),
    max_temp_f = vapply(temps, function(t) t$max_f, character(1)),
    max_temp_c = vapply(temps, function(t) t$max_c, character(1))
  )
}

weather_temp <- function(temp) {
  if (is.null(temp) || length(temp) == 0) {
    return(list(
      temp_f = NA_character_, temp_c = NA_character_,
      min_f = NA_character_, min_c = NA_character_,
      max_f = NA_character_, max_c = NA_character_
    ))
  }
  list(
    temp_f = temp$tempF %||% NA_character_,
    temp_c = temp$tempC %||% NA_character_,
    min_f = temp$minTempF %||% NA_character_,
    min_c = temp$minTempC %||% NA_character_,
    max_f = temp$maxTempF %||% NA_character_,
    max_c = temp$maxTempC %||% NA_character_
  )
}
