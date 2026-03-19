#' Convert camelCase to snake_case
#' @param x Character vector.
#' @return Character vector in snake_case.
#' @noRd
to_snake_case <- function(x) {
  out <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", x)
  tolower(out)
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
validate_tour_code <- function(tour) {
  valid <- c("R", "S", "H")
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
