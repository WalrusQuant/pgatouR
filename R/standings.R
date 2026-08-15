#' Get signature-event standings
#'
#' Official and interim signature-event tables (Aon / signature series).
#'
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble with one row per player per table (`table` is
#'   `"official"` or `"interim"`).
#' @export
#' @examples
#' \dontrun{
#' pga_signature_standings()
#' }
pga_signature_standings <- function(tour = "R") {
  validate_tour_code(tour)
  data <- pga_graphql_request("SignatureStandings", list(tourCode = tour))
  ss <- data$signatureStandings
  if (is.null(ss)) {
    cli_abort("No signature standings returned for tour {.val {tour}}.")
  }

  pieces <- Filter(Negate(is.null), list(
    signature_players(ss$official, "official", ss),
    signature_players(ss$interim, "interim", ss)
  ))
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}

#' Get priority / exemption rankings
#'
#' The player-directory priority ranking categories (winners of majors,
#' career earnings, etc.).
#'
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @param year Integer or `NULL`. Season year.
#' @return A tibble with one row per category-player.
#' @export
#' @examples
#' \dontrun{
#' pga_priority_rankings()
#' }
pga_priority_rankings <- function(tour = "R", year = NULL) {
  validate_tour_code(tour)
  variables <- list(tourCode = tour)
  if (!is.null(year)) variables$year <- as.integer(year)

  data <- pga_graphql_request("PriorityRankings", variables)
  pr <- data$priorityRankings
  if (is.null(pr)) {
    cli_abort("No priority rankings returned for tour {.val {tour}}.")
  }

  pieces <- list()
  for (i in seq_along(pr$categories %||% list())) {
    cat <- pr$categories[[i]]
    players <- cat$players %||% list()
    if (length(players) == 0) next
    pieces[[length(pieces) + 1]] <- tibble(
      tour = pr$tourCode %||% tour,
      year = as.integer(pr$year %||% year %||% NA_integer_),
      through = pr$throughText %||% NA_character_,
      category_rank = i,
      category = cat$displayName %||% NA_character_,
      detail = cat$detail %||% NA_character_,
      player_id = vapply(players, function(p) p$playerId %||% NA_character_, character(1)),
      display_name = vapply(players, function(p) p$displayName %||% NA_character_, character(1))
    )
  }
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}

#' Get FedExCup / playoff bubble
#'
#' Cutoff lines and nearby players for the current playoff or tour-card
#' bubble, when the API is publishing one for this tournament.
#'
#' @param tournament_id Character. Tournament ID.
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble of ranking rows around the cutoff.
#' @export
pga_bubble <- function(tournament_id, tour = "R") {
  validate_tour_code(tour)
  data <- pga_graphql_request(
    "Bubble",
    list(tourCode = tour, tournamentId = tournament_id)
  )
  bubble <- data$bubble
  if (is.null(bubble)) {
    return(tibble())
  }

  pieces <- list()
  for (item in bubble$items %||% list()) {
    standings <- item$standings
    rankings <- standings$rankings %||% list()
    is_player <- vapply(rankings, function(r) {
      identical(r[["__typename"]], "CupRankingPlayer")
    }, logical(1))
    rows <- rankings[is_player]
    if (length(rows) == 0) next
    pieces[[length(pieces) + 1]] <- tibble(
      tournament_id = tournament_id,
      tour = tour,
      bubble_id = bubble$bubbleId %||% NA_character_,
      bubble_type = bubble$bubbleType %||% NA_character_,
      cutoff_included = isTRUE(bubble$cutoffIncluded),
      info = item$info %||% NA_character_,
      info_desc = item$infoDesc %||% NA_character_,
      standings_id = standings$id %||% NA_character_,
      standings_title = standings$title %||% NA_character_,
      player_id = vapply(rows, function(r) r$id %||% NA_character_, character(1)),
      display_name = vapply(rows, function(r) r$name %||% NA_character_, character(1)),
      country = vapply(rows, function(r) r$playerCountry %||% NA_character_, character(1)),
      position = vapply(rows, function(r) r$position %||% NA_character_, character(1)),
      total = vapply(rows, function(r) r$total %||% NA_character_, character(1)),
      movement = vapply(rows, function(r) r$movement %||% NA_character_, character(1)),
      movement_direction = vapply(rows, function(r) r$movementDirection %||% NA_character_, character(1)),
      points_delta = vapply(rows, function(r) r$pointsDelta %||% NA_character_, character(1))
    )
  }
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}

#' Get default tour-cup standings
#'
#' Simpler cup table than [pga_fedex_cup()]: uses `defaultTourCup`, so the
#' correct cup is selected per tour (FedExCup, Schwab, Fortinet, Americas
#' points).
#'
#' @param year Integer. Season year. Defaults to the current year.
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble of cup ranking rows.
#' @export
pga_cup_standings <- function(year = as.integer(format(Sys.Date(), "%Y")),
                              tour = "R") {
  validate_tour_code(tour)
  data <- pga_graphql_request(
    "TourCupStandings",
    list(tour = tour, year = as.integer(year))
  )
  cup <- data$defaultTourCup
  if (is.null(cup)) {
    cli_abort("No cup standings returned for tour {.val {tour}}, year {year}.")
  }

  rankings <- cup$rankings
  if (is.null(rankings) || length(rankings) == 0) {
    return(tibble())
  }
  is_player <- vapply(rankings, function(r) {
    identical(r[["__typename"]], "CupRankingPlayer")
  }, logical(1))
  rows <- rankings[is_player]
  if (length(rows) == 0) {
    return(tibble())
  }

  tibble(
    tour = tour,
    year = as.integer(year),
    cup_id = cup$id %||% NA_character_,
    title = cup$title %||% NA_character_,
    live = isTRUE(cup$live),
    player_id = vapply(rows, function(r) r$id %||% NA_character_, character(1)),
    display_name = vapply(rows, function(r) r$name %||% NA_character_, character(1)),
    country = vapply(rows, function(r) r$playerCountry %||% NA_character_, character(1)),
    position = vapply(rows, function(r) r$position %||% NA_character_, character(1)),
    total = vapply(rows, function(r) r$total %||% NA_character_, character(1)),
    total_display = vapply(rows, function(r) safe_pluck(r, "totals", "display") %||% NA_character_, character(1)),
    movement = vapply(rows, function(r) r$movement %||% NA_character_, character(1)),
    movement_direction = vapply(rows, function(r) r$movementDirection %||% NA_character_, character(1)),
    winner = vapply(rows, function(r) isTRUE(r$winner), logical(1))
  )
}

#' List all-time record categories
#'
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble of record IDs with category / subcategory labels.
#' @export
pga_all_time_record_categories <- function(tour = "R") {
  validate_tour_code(tour)
  data <- pga_graphql_request("AllTimeRecordCategories", list(tourCode = tour))
  cats <- data$allTimeRecordCategories
  if (is.null(cats)) {
    cli_abort("No all-time record categories returned for tour {.val {tour}}.")
  }

  pieces <- list()
  for (cat in cats$categories %||% list()) {
    for (sub in cat$subCategories %||% list()) {
      stats <- sub$statistics %||% list()
      if (length(stats) == 0) next
      pieces[[length(pieces) + 1]] <- tibble(
        tour = cats$tourCode %||% tour,
        category_id = cat$categoryId %||% NA_character_,
        category = cat$displayText %||% NA_character_,
        subcategory = sub$displayText %||% NA_character_,
        record_id = vapply(stats, function(s) s$recordId %||% NA_character_, character(1)),
        record_name = vapply(stats, function(s) s$displayText %||% NA_character_, character(1))
      )
    }
  }
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}

#' Get an all-time record table
#'
#' @param record_id Character. Record ID from
#'   [pga_all_time_record_categories()].
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble with one row per record holder. Dynamic columns come
#'   from the API headers.
#' @export
pga_all_time_records <- function(record_id, tour = "R") {
  validate_tour_code(tour)
  data <- pga_graphql_request(
    "AllTimeRecordStat",
    list(tourCode = tour, recordId = record_id)
  )
  rec <- data$allTimeRecordStat
  if (is.null(rec)) {
    cli_abort("No all-time record returned for {.val {record_id}}.")
  }

  rows <- rec$rows
  if (is.null(rows) || length(rows) == 0) {
    return(tibble())
  }

  headers <- rec$statHeaders %||% character()
  base <- tibble(
    tour = tour,
    record_id = rec$recordId %||% record_id,
    title = rec$title %||% NA_character_,
    category = rec$categoryName %||% NA_character_,
    subcategory = rec$subCategoryName %||% NA_character_,
    player_id = vapply(rows, function(r) r$playerId %||% NA_character_, character(1))
  )

  if (length(headers) > 0) {
    extra <- lapply(seq_along(headers), function(i) {
      vapply(rows, function(r) {
        vals <- r$values
        if (is.null(vals) || length(vals) < i) return(NA_character_)
        vals[[i]] %||% NA_character_
      }, character(1))
    })
    names(extra) <- make_unique_snake(headers)
    base <- vec_cbind(base, as_tibble(extra))
  }
  base
}

#' Get PGA TOUR University rankings
#'
#' @param year Integer or `NULL`. Season year.
#' @param week Integer or `NULL`. Ranking week.
#' @return A tibble with one row per player.
#' @export
pga_university_rankings <- function(year = NULL, week = NULL) {
  variables <- list()
  if (!is.null(year)) variables$year <- as.integer(year)
  if (!is.null(week)) variables$week <- as.integer(week)

  data <- pga_graphql_request("UniversityRankings", variables)
  ur <- data$universityRankings
  if (is.null(ur)) {
    cli_abort("No university rankings returned.")
  }

  players <- ur$players
  if (is.null(players) || length(players) == 0) {
    return(tibble())
  }

  tibble(
    year = as.integer(ur$year %||% year %||% NA_integer_),
    week = as.integer(ur$weekNum %||% week %||% NA_integer_),
    through = ur$throughText %||% NA_character_,
    title = ur$title %||% NA_character_,
    player_id = vapply(players, function(p) p$playerId %||% NA_character_, character(1)),
    display_name = vapply(players, function(p) p$displayName %||% NA_character_, character(1)),
    school = vapply(players, function(p) p$schoolName %||% NA_character_, character(1)),
    country = vapply(players, function(p) p$country %||% NA_character_, character(1)),
    rank = vapply(players, function(p) as_chr(p$rank), character(1)),
    movement = vapply(players, function(p) as_chr(p$rankingMovement), character(1)),
    movement_amount = vapply(players, function(p) as_chr(p$rankingMovementAmount), character(1)),
    wins = vapply(players, function(p) as_chr(p$wins), character(1)),
    top_10 = vapply(players, function(p) as_chr(p$top10), character(1)),
    average = vapply(players, function(p) as_chr(p$avg), character(1)),
    events = vapply(players, function(p) as_chr(p$events), character(1))
  )
}

signature_players <- function(tbl, table_name, ss) {
  if (is.null(tbl) || !is.list(tbl)) {
    return(NULL)
  }
  players <- tbl$players %||% list()
  is_player <- vapply(players, function(p) {
    identical(p[["__typename"]], "SignaturePlayer")
  }, logical(1))
  rows <- players[is_player]
  if (length(rows) == 0) {
    return(NULL)
  }
  tibble(
    tournament_id = ss$tournamentID %||% NA_character_,
    table_name = table_name,
    title = tbl$title %||% NA_character_,
    player_id = vapply(rows, function(p) p$playerId %||% NA_character_, character(1)),
    display_name = vapply(rows, function(p) p$displayName %||% NA_character_, character(1)),
    short_name = vapply(rows, function(p) p$shortName %||% NA_character_, character(1)),
    country = vapply(rows, function(p) p$countryName %||% NA_character_, character(1)),
    country_flag = vapply(rows, function(p) p$countryFlag %||% NA_character_, character(1)),
    started = vapply(rows, function(p) as_chr(p$started), character(1)),
    projected = vapply(rows, function(p) as_chr(p$projected), character(1)),
    projected_points = vapply(rows, function(p) as_chr(p$projectedPoints), character(1)),
    movement_amount = vapply(rows, function(p) as_chr(p$movementAmount), character(1)),
    movement_direction = vapply(rows, function(p) as_chr(p$movementDirection), character(1))
  )
}
