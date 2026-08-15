#' Get odds to win for a tournament
#'
#' Returns betting odds for each player in the tournament field.
#'
#' @param tournament_id Character. Tournament ID (e.g., `"R2026475"`).
#' @return A tibble with player odds data.
#' @export
#' @examples
#' \dontrun{
#' pga_odds("R2026475")
#' }
pga_odds <- function(tournament_id) {
  data <- pga_graphql_request(
    "oddsToWinCompressed",
    list(tournamentId = tournament_id)
  )

  payload <- data$oddsToWinCompressed$payload
  if (is.null(payload)) {
    cli_abort("No odds data returned for tournament {.val {tournament_id}}.")
  }

  parsed <- pga_decompress(payload)

  # Structure varies — try common patterns
  players <- parsed$players %||% parsed$odds %||% parsed$rows
  if (is.null(players) || length(players) == 0) {
    # If the parsed data is itself a data.frame
    if (is.data.frame(parsed)) {
      return(clean_names(as_tibble(parsed)))
    }
    return(tibble())
  }

  if (is.data.frame(players)) {
    return(clean_names(as_tibble(players)))
  }

  # Fallback: return the full parsed structure as a tibble if possible
  tryCatch(
    clean_names(as_tibble(as.data.frame(players, stringsAsFactors = FALSE))),
    error = function(e) {
      cli_warn("Could not flatten odds data to tibble. Returning raw list.")
      tibble(raw_data = list(parsed))
    }
  )
}

#' Get available betting markets for a tournament
#'
#' REST catalog of FanDuel (or current book) markets: outright, matchups,
#' finishes, groups, player props, 3-ball, nationality.
#'
#' @param tournament_id Character. Tournament ID.
#' @return A tibble with one row per market.
#' @export
#' @examples
#' \dontrun{
#' pga_odds_markets("R2026027")
#' }
pga_odds_markets <- function(tournament_id) {
  resp <- pga_rest_request(paste0("odds/tournament/", tournament_id))
  markets <- resp$availableMarkets
  if (is.null(markets) || length(markets) == 0) {
    return(tibble())
  }
  tibble(
    tournament_id = tournament_id,
    market_id = vapply(markets, function(m) as.character(m$id %||% NA_character_), character(1)),
    name = vapply(markets, function(m) m$name %||% NA_character_, character(1)),
    display_name = vapply(markets, function(m) m$displayName %||% NA_character_, character(1)),
    market_type = vapply(markets, function(m) m$marketType %||% NA_character_, character(1)),
    book = vapply(markets, function(m) m$book %||% NA_character_, character(1)),
    drawers_enabled = isTRUE(resp$areDrawersEnabled)
  )
}

#' Get betting markets for one player
#'
#' Per-player finish / prop / matchup lines from
#' `/odds/tournament/{id}/player/{id}`.
#'
#' @param tournament_id Character. Tournament ID.
#' @param player_id Character. Player ID.
#' @return A tibble with one row per quoted line.
#' @export
#' @examples
#' \dontrun{
#' pga_odds_player("R2026027", "46046")
#' }
pga_odds_player <- function(tournament_id, player_id) {
  resp <- pga_rest_request(
    paste0("odds/tournament/", tournament_id, "/player/", player_id)
  )
  markets <- resp$playerMarkets
  if (is.null(markets) || length(markets) == 0) {
    return(tibble())
  }

  pieces <- list()
  for (mkt in markets) {
    for (grp in mkt$oddsDataGroup %||% list()) {
      for (block in grp$oddsData %||% list()) {
        for (line in block$group %||% list()) {
          players <- line$players %||% list()
          pieces[[length(pieces) + 1]] <- tibble(
            tournament_id = tournament_id,
            player_id = player_id,
            market_type = mkt$marketType %||% NA_character_,
            market_name = mkt$marketDisplayName %||% mkt$subMarketName %||% NA_character_,
            submarket = mkt$subMarketName %||% NA_character_,
            line_title = grp$title %||% NA_character_,
            line_type = block$type %||% NA_character_,
            odds = line$oddsValue %||% NA_character_,
            odds_direction = line$oddDirection %||% NA_character_,
            option_id = line$optionId %||% NA_character_,
            entity_id = line$entityId %||% NA_character_,
            url = line$url %||% NA_character_,
            participants = paste(
              vapply(players, function(p) p$displayName %||% p$playerId %||% "", character(1)),
              collapse = " / "
            )
          )
        }
      }
    }
  }
  if (length(pieces) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, pieces)
}
