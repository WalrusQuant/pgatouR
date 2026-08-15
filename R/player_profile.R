#' Get player profile overview
#'
#' Returns a player's profile summary including career highlights,
#' wins, earnings, world ranking, FedExCup standing, and bio basics.
#'
#' @param player_id Character. Player ID (e.g., `"52955"` for Ludvig Aberg).
#' @return A named list with scalar bio fields (`player_id`, `first_name`,
#'   `last_name`, `country`, `country_code`, `born`, `age`, `birthplace`,
#'   `college`, `turned_pro`) plus two tibbles: `highlights` (career highlight
#'   cards) and `overview` (overview-stats grid).
#' @export
#' @examples
#' \dontrun{
#' pga_player_profile("52955")
#' }
pga_player_profile <- function(player_id) {
  resp <- pga_rest_request(paste0("player/profiles/", player_id))

  summary_data <- safe_pluck(resp, "summaryData", "summaryData")
  if (is.null(summary_data)) {
    cli_abort("No profile data returned for player {.val {player_id}}.")
  }

  highlights <- summary_data$careerHighlights
  highlight_rows <- if (!is.null(highlights) && length(highlights) > 0) {
    tibble(
      title = vapply(highlights, function(h) h$title %||% NA_character_, character(1)),
      value = vapply(highlights, function(h) h$data %||% NA_character_, character(1)),
      subtitle = vapply(highlights, function(h) h$subTitle %||% NA_character_, character(1))
    )
  } else {
    tibble()
  }

  overview_stats <- list()
  for (section in resp$overview %||% list()) {
    if (identical(section$type, "OVERVIEW_STATS")) {
      for (item in section$items %||% list()) {
        for (el in item$elements %||% list()) {
          overview_stats[[length(overview_stats) + 1]] <- list(
            section = item$title,
            subtitle = item$subtitle,
            title = el$title,
            value = el$data
          )
        }
      }
    }
  }

  overview_df <- if (length(overview_stats) > 0) {
    tibble(
      section = vapply(overview_stats, function(x) x$section %||% NA_character_, character(1)),
      subtitle = vapply(overview_stats, function(x) x$subtitle %||% NA_character_, character(1)),
      title = vapply(overview_stats, function(x) x$title %||% NA_character_, character(1)),
      value = vapply(overview_stats, function(x) x$value %||% NA_character_, character(1))
    )
  } else {
    tibble()
  }

  list(
    player_id = resp$playerId %||% NA_character_,
    first_name = summary_data$firstName,
    last_name = summary_data$lastName,
    country = summary_data$country,
    country_code = summary_data$countryCode,
    born = summary_data$born,
    age = summary_data$age,
    birthplace = summary_data$birthplace,
    college = summary_data$college,
    turned_pro = summary_data$turnedPro,
    highlights = highlight_rows,
    overview = overview_df
  )
}

#' Get player career data
#'
#' Returns a player's career achievements including starts, cuts,
#' wins, finish distribution, and earnings.
#'
#' @param player_id Character. Player ID.
#' @return A tibble of career statistics.
#' @export
#' @examples
#' \dontrun{
#' pga_player_career("52955")
#' }
pga_player_career <- function(player_id) {
  resp <- pga_rest_request(paste0("player/profiles/", player_id, "/career"))

  career_list <- resp$career
  if (is.null(career_list) || length(career_list) == 0) {
    return(tibble())
  }

  rows <- list()
  for (tour_data in career_list) {
    tour_code <- tour_data$tourCode %||% NA_character_
    tour_name <- tour_data$tourName %||% NA_character_
    for (section in tour_data$careerData %||% list()) {
      for (widget in section$stats %||% list()) {
        widget_title <- widget$title %||% NA_character_
        for (item in widget$data %||% list()) {
          rows[[length(rows) + 1]] <- tibble(
            tour_code = tour_code,
            tour_name = tour_name,
            section = section$title,
            widget = widget_title,
            label = item$label %||% NA_character_,
            value = item$data %||% NA_character_
          )
        }
      }
    }
  }

  if (length(rows) == 0) return(tibble())
  do.call(vec_rbind, rows)
}

#' Get player tournament results
#'
#' Returns a player's tournament-by-tournament results, including round
#' scores, finish position, FedExCup points, and earnings. If the upstream
#' response contains multiple seasons, all are returned and tagged with a
#' `season` column.
#'
#' @param player_id Character. Player ID.
#' @return A tibble with one row per tournament. Includes a `season` column
#'   (the season label or index from the API response).
#' @export
#' @examples
#' \dontrun{
#' pga_player_results("52955")
#' }
pga_player_results <- function(player_id) {
  resp <- pga_rest_request(paste0("player/profiles/", player_id, "/results"))

  results_list <- resp$resultsData
  if (is.null(results_list) || length(results_list) == 0) {
    return(tibble())
  }

  season_tibbles <- lapply(seq_along(results_list), function(i) {
    season_obj <- results_list[[i]]
    season_label <- season_obj$season %||% season_obj$year %||%
      season_obj$displaySeason %||% as.character(i)
    parse_player_results_season(season_obj, season_label)
  })

  do.call(vec_rbind, season_tibbles)
}

# Parse one season of player results into a tibble with a `season` column.
parse_player_results_season <- function(season_obj, season_label) {
  headers <- season_obj$headers
  data_rows <- season_obj$data
  if (is.null(data_rows) || length(data_rows) == 0) return(tibble())

  header_labels <- character()
  for (h in headers) {
    if (!is.null(h$label)) {
      header_labels <- c(header_labels, h$label)
    } else if (!is.null(h$labels)) {
      prefix <- h$groupLabel %||% ""
      for (sub in h$labels) {
        header_labels <- c(header_labels, trimws(paste(prefix, sub)))
      }
    }
  }
  col_names <- if (length(header_labels) > 0) {
    make_unique_snake(header_labels)
  } else {
    character()
  }

  rows <- lapply(data_rows, function(d) {
    fields <- d$fields
    row <- list(
      season = as.character(season_label),
      tournament_id = d$tournamentId %||% NA_character_
    )
    for (i in seq_along(fields)) {
      nm <- if (i <= length(col_names)) col_names[i] else paste0("field_", i)
      val <- fields[[i]]
      row[[nm]] <- if (is.null(val)) NA_character_ else val
    }
    as_tibble(row)
  })

  do.call(vec_rbind, rows)
}

#' Get player stats profile
#'
#' Returns a player's full statistical profile with ranks and values
#' for 130+ stats in a single call. Much more efficient than pulling
#' individual stats with [pga_stats()].
#'
#' @param player_id Character. Player ID.
#' @return A tibble with one row per stat including stat_id, title,
#'   rank, value, category, and supporting stats.
#' @export
#' @examples
#' \dontrun{
#' pga_player_stats("52955")
#' }
pga_player_stats <- function(player_id) {
  resp <- pga_rest_request(paste0("player/profiles/", player_id, "/stats"))

  stats <- resp$stats
  if (is.null(stats) || length(stats) == 0) {
    return(tibble())
  }

  tibble(
    stat_id = vapply(stats, function(s) s$statId %||% NA_character_, character(1)),
    title = vapply(stats, function(s) s$title %||% NA_character_, character(1)),
    rank = vapply(stats, function(s) {
      suppressWarnings(as.integer(s$rank %||% NA))
    }, integer(1)),
    value = vapply(stats, function(s) s$value %||% NA_character_, character(1)),
    category = vapply(stats, function(s) {
      cats <- s$category
      if (is.null(cats)) return(NA_character_)
      paste(cats, collapse = ", ")
    }, character(1)),
    above_or_below = vapply(stats, function(s) s$aboveOrBelow %||% NA_character_, character(1)),
    field_average = vapply(stats, function(s) s$fieldAverage %||% NA_character_, character(1)),
    supporting_stat_desc = vapply(stats, function(s) {
      safe_pluck(s, "supportingStat", "description") %||% NA_character_
    }, character(1)),
    supporting_stat_value = vapply(stats, function(s) {
      safe_pluck(s, "supportingStat", "value") %||% NA_character_
    }, character(1)),
    supporting_value_desc = vapply(stats, function(s) {
      safe_pluck(s, "supportingValue", "description") %||% NA_character_
    }, character(1)),
    supporting_value_value = vapply(stats, function(s) {
      safe_pluck(s, "supportingValue", "value") %||% NA_character_
    }, character(1))
  )
}

#' Get player bio
#'
#' Returns a player's biographical text, amateur highlights, and any
#' available widget data (physical stats, exempt status, location, personal).
#'
#' @param player_id Character. Player ID.
#' @return A named list with `text` (character vector of bio paragraphs),
#'   `amateur_highlights` (character vector), and `widgets` (tibble).
#' @export
#' @examples
#' \dontrun{
#' pga_player_bio("52955")
#' }
pga_player_bio <- function(player_id) {
  resp <- pga_rest_request(paste0("player/profiles/", player_id, "/bio"))

  bio <- resp$bio %||% list()
  widgets <- resp$widgets %||% list()

  # Bio text paragraphs
  bio_text <- bio$elements %||% character()
  if (is.list(bio_text)) {
    bio_text <- vapply(bio_text, function(x) {
      if (is.character(x)) x else NA_character_
    }, character(1))
  }

  # Amateur highlights
  amateur <- bio$amateurHighlights %||% character()
  if (is.list(amateur)) {
    amateur <- vapply(amateur, function(x) {
      if (is.character(x)) x else NA_character_
    }, character(1))
  }

  # Widgets (may be empty)
  widget_rows <- list()
  for (w in widgets) {
    w_title <- w$title %||% NA_character_
    w_type <- w$type %||% NA_character_
    for (item in w$items %||% list()) {
      widget_rows[[length(widget_rows) + 1]] <- tibble(
        widget_type = w_type,
        widget_title = w_title,
        label = item$label %||% NA_character_,
        value = item$value %||% NA_character_
      )
    }
  }

  widget_df <- if (length(widget_rows) > 0) {
    do.call(vec_rbind, widget_rows)
  } else {
    tibble()
  }

  list(
    text = bio_text,
    amateur_highlights = amateur,
    widgets = widget_df
  )
}

#' Get player tournament status
#'
#' Returns a player's status in the current tournament (if playing),
#' including position, score, and tee time.
#'
#' @param player_id Character. Player ID.
#' @return A tibble with one row, or empty if the player is not in
#'   the current tournament.
#' @export
#' @examples
#' \dontrun{
#' pga_player_tournament_status("52955")
#' }
pga_player_tournament_status <- function(player_id) {
  data <- pga_graphql_request(
    "getPlayerTournamentStatus",
    list(playerId = player_id)
  )

  status <- data$playerTournamentStatus
  if (is.null(status)) {
    return(tibble())
  }

  # The API sometimes returns a status object whose fields are all null
  # (player not in a current tournament). Treat that as "empty" too, so the
  # function's contract is binary: either a real row, or zero rows.
  scalar_fields <- c("playerId", "tournamentId", "tournamentName",
                     "position", "score", "total", "displayMode")
  if (all(vapply(scalar_fields, function(k) is.null(status[[k]]),
                 logical(1)))) {
    return(tibble())
  }

  tibble(
    player_id = status$playerId %||% NA_character_,
    tournament_id = status$tournamentId %||% NA_character_,
    tournament_name = status$tournamentName %||% NA_character_,
    position = status$position %||% NA_character_,
    thru = status$thru %||% NA_character_,
    score = status$score %||% NA_character_,
    total = status$total %||% NA_character_,
    round_display = status$roundDisplay %||% NA_character_,
    round_status = status$roundStatus %||% NA_character_,
    round_status_display = status$roundStatusDisplay %||% NA_character_,
    round_status_color = status$roundStatusColor %||% NA_character_,
    tee_time = status$teeTime %||% NA_character_,
    display_mode = status$displayMode %||% NA_character_
  )
}

#' Get a player's recent values for one stat
#'
#' Event-by-event series for a single stat (e.g. SG: Total across the last
#' ten starts).
#'
#' @param player_id Character. Player ID.
#' @param stat_id Character. Stat ID (see [stat_ids]).
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble with one row per event, plus player-level metadata
#'   columns (`rank`, `player_avg`, `tour_avg`).
#' @export
#' @examples
#' \dontrun{
#' pga_player_finish_stats("46046", "02675")
#' }
pga_player_finish_stats <- function(player_id, stat_id, tour = "R") {
  validate_tour_code(tour)
  data <- pga_graphql_request(
    "PlayerFinishStats",
    list(playerId = player_id, statId = stat_id, tourCode = tour)
  )
  fs <- data$playerFinishStats
  if (is.null(fs)) {
    cli_abort("No finish stats returned for player {.val {player_id}}, stat {.val {stat_id}}.")
  }

  values <- fs$statValues
  if (is.null(values) || length(values) == 0) {
    return(tibble())
  }

  tibble(
    player_id = fs$playerId %||% player_id,
    display_name = fs$displayName %||% NA_character_,
    country = fs$countryName %||% NA_character_,
    country_code = fs$countryCode %||% NA_character_,
    stat_id = fs$statId %||% stat_id,
    stat_name = fs$statName %||% NA_character_,
    rank = fs$rank %||% NA_character_,
    player_avg = fs$playerAvg %||% NA_character_,
    player_avg_label = fs$playerAvgLabel %||% NA_character_,
    tour_avg = fs$tourAvg %||% NA_character_,
    value = vapply(values, function(v) as_chr(v$value), character(1)),
    display_value = vapply(values, function(v) as_chr(v$displayValue), character(1)),
    date = vapply(values, function(v) as_chr(v$date), character(1)),
    display_date = vapply(values, function(v) as_chr(v$displayDate), character(1)),
    tournament_name = vapply(values, function(v) as_chr(v$tournamentName), character(1))
  )
}
