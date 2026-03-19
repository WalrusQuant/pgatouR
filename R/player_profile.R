#' Get player profile overview
#'
#' Returns a player's profile summary including career highlights,
#' wins, earnings, world ranking, FedExCup standing, and bio basics.
#'
#' @param player_id Character. Player ID (e.g., `"52955"` for Ludvig Aberg).
#' @return A named list with `summary` (tibble of career highlights) and
#'   `bio` (list of biographical info).
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
    player_id = resp$playerId,
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
  do.call(rbind, rows)
}

#' Get player tournament results
#'
#' Returns a player's tournament-by-tournament results for a season
#' including round scores, finish position, FedExCup points, and earnings.
#'
#' @param player_id Character. Player ID.
#' @return A tibble with one row per tournament.
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

  results <- results_list[[1]]
  headers <- results$headers
  data_rows <- results$data

  if (is.null(data_rows) || length(data_rows) == 0) {
    return(tibble())
  }

  # Build header labels
  header_labels <- character()
  for (h in headers) {
    if (!is.null(h$label)) {
      header_labels <- c(header_labels, h$label)
    } else if (!is.null(h$labels)) {
      prefix <- h$groupLabel %||% ""
      for (sub in h$labels) {
        header_labels <- c(header_labels, paste(prefix, sub))
      }
    }
  }

  rows <- list()
  for (d in data_rows) {
    fields <- d$fields
    row <- list(tournament_id = d$tournamentId)
    for (i in seq_along(fields)) {
      col_name <- if (i <= length(header_labels)) {
        to_snake_case(gsub("[^a-zA-Z0-9 ]", "", header_labels[i]))
      } else {
        paste0("field_", i)
      }
      row[[col_name]] <- fields[[i]]
    }
    rows[[length(rows) + 1]] <- as_tibble(row)
  }

  if (length(rows) == 0) return(tibble())
  do.call(rbind, rows)
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
    rank = vapply(stats, function(s) s$rank %||% NA_character_, character(1)),
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
    do.call(rbind, widget_rows)
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
    tee_time = status$teeTime %||% NA_character_,
    display_mode = status$displayMode %||% NA_character_
  )
}
