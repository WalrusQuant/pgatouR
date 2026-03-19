#' PGA Tour Stat ID Lookup Table
#'
#' A tibble containing all known PGA Tour stat IDs, names, and categories.
#' Use with [pga_stats()] to look up valid stat IDs.
#'
#' @format A tibble with 4 columns:
#' \describe{
#'   \item{stat_id}{Character. The stat ID to pass to [pga_stats()].}
#'   \item{stat_name}{Character. Human-readable stat name.}
#'   \item{category}{Character. Top-level category (e.g., "Strokes Gained", "Putting").}
#'   \item{subcategory}{Character. Subcategory (e.g., "Driving Leaders", "Putts per Round").}
#' }
#'
#' @examples
#' # Browse all strokes gained stats
#' stat_ids[stat_ids$category == "Strokes Gained", ]
#'
#' # Find a stat by name
#' stat_ids[grep("Driving Distance", stat_ids$stat_name), ]
"stat_ids"
