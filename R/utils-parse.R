#' Default-value operator (back-port for R < 4.4)
#'
#' Base R 4.4 added `%||%`, but the package declares `Depends: R (>= 4.1.0)`.
#' Define it locally so the package works on older R without depending on
#' rlang's re-export being on the search path.
#' @noRd
#' @keywords internal
`%||%` <- function(x, y) if (is.null(x)) y else x

#' Convert camelCase to snake_case
#' @param x Character vector.
#' @return Character vector in snake_case.
#' @noRd
to_snake_case <- function(x) {
  out <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", x)
  tolower(out)
}

#' Sanitize free-form labels into unique snake_case column names
#'
#' Strips punctuation, collapses whitespace to underscores, lowercases, and
#' applies `make.unique()` so duplicate labels get `_1`, `_2`, ... suffixes.
#' Use this for API headers that may contain spaces, dots, or repeats.
#' @param x Character vector.
#' @return Character vector of unique snake_case names.
#' @noRd
make_unique_snake <- function(x) {
  out <- to_snake_case(x)
  out <- gsub("[^a-z0-9]+", "_", out)
  out <- gsub("^_+|_+$", "", out)
  out[!nzchar(out)] <- "col"
  make.unique(out, sep = "_")
}

#' Clean column names of a data frame to snake_case
#' @param df A data frame.
#' @return The data frame with snake_case column names.
#' @noRd
clean_names <- function(df) {
  names(df) <- to_snake_case(names(df))
  df
}

#' Validate tour code
#' @param tour Character.
#' @noRd
# First-class tours in the PGA Tour frontend `currentTours` config.
.pga_tour_codes <- c(
  "R" = "PGA Tour",
  "S" = "PGA Tour Champions",
  "H" = "Korn Ferry Tour",
  "Y" = "PGA Tour Americas"
)

validate_tour_code <- function(tour) {
  valid <- names(.pga_tour_codes)
  if (!tour %in% valid) {
    cli_abort(c(
      "Invalid tour code: {.val {tour}}",
      "i" = "Must be one of: {.val {valid}}"
    ))
  }
  invisible(tour)
}

#' Safe list access that returns NULL instead of erroring
#' @param x A list.
#' @param ... Names or indices to traverse.
#' @return The value at the path, or NULL.
#' @noRd
#' Coerce a scalar (or first element) to character, treating NULL as NA.
#' @noRd
as_chr <- function(x) {
  if (is.null(x) || length(x) == 0) {
    return(NA_character_)
  }
  as.character(x[[1]])
}

safe_pluck <- function(x, ...) {
  tryCatch(
    {
      path <- list(...)
      for (key in path) {
        x <- x[[key]]
      }
      x
    },
    error = function(e) NULL
  )
}

#' Flatten a decompressed payload into a tibble
#'
#' Compressed operations come back as data.frames (via `pga_decompress`) or
#' a list whose first tabular field is `players` / `rows` / `odds`.
#' @noRd
flatten_decompressed <- function(parsed) {
  if (is.data.frame(parsed)) {
    return(clean_names(as_tibble(parsed)))
  }
  if (!is.list(parsed)) {
    return(tibble())
  }
  for (key in c("players", "odds", "rows", "data", "items")) {
    obj <- parsed[[key]]
    if (is.null(obj) || length(obj) == 0) next
    if (is.data.frame(obj)) {
      return(clean_names(as_tibble(obj)))
    }
    if (is.list(obj)) {
      return(tryCatch(
        clean_names(as_tibble(obj)),
        error = function(e) tibble(raw = list(parsed))
      ))
    }
  }
  tryCatch(
    clean_names(as_tibble(parsed)),
    error = function(e) tibble(raw = list(parsed))
  )
}

#' One row per player-stat from a LeaderboardStats payload.
#' @noRd
flatten_leaderboard_stats <- function(stats) {
  expand_players <- function(players, round_number = NA_integer_,
                             round_display = NA_character_) {
    if (is.null(players) || length(players) == 0) {
      return(NULL)
    }
    pieces <- lapply(players, function(p) {
      items <- p$stats
      if (is.null(items) || length(items) == 0) {
        return(NULL)
      }
      tibble(
        player_id = p$playerId %||% NA_character_,
        round_number = round_number,
        round_display = round_display,
        stat_id = vapply(items, function(s) s$statId %||% NA_character_, character(1)),
        value = vapply(items, function(s) s$value %||% NA_character_, character(1)),
        sort_value = vapply(items, function(s) s$sortValue %||% NA_character_, character(1)),
        rank = vapply(items, function(s) s$rank %||% NA_character_, character(1)),
        color = vapply(items, function(s) s$color %||% NA_character_, character(1))
      )
    })
    pieces <- Filter(Negate(is.null), pieces)
    if (length(pieces) == 0) NULL else do.call(vec_rbind, pieces)
  }

  chunks <- list(expand_players(stats$players))
  for (rnd in stats$rounds %||% list()) {
    chunks[[length(chunks) + 1]] <- expand_players(
      rnd$players,
      as.integer(rnd$roundNumber %||% NA_integer_),
      rnd$roundDisplayText %||% NA_character_
    )
  }
  chunks <- Filter(Negate(is.null), chunks)
  if (length(chunks) == 0) {
    return(tibble())
  }
  do.call(vec_rbind, chunks)
}
