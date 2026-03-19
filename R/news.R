#' Get news articles
#'
#' Returns PGA Tour news articles with optional filtering.
#'
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @param franchises Character vector or NULL. Filter by franchise categories.
#' @param player_ids Character vector or NULL. Filter by player IDs.
#' @param limit Integer. Maximum number of articles. Defaults to 20.
#' @param offset Integer. Pagination offset. Defaults to 0.
#' @return A tibble with one row per article.
#' @export
#' @examples
#' \dontrun{
#' pga_news()
#' pga_news(limit = 5)
#' }
pga_news <- function(tour = "R", franchises = NULL, player_ids = NULL,
                     limit = 20L, offset = 0L) {
  validate_tour_code(tour)

  variables <- list(
    tour = tour,
    limit = as.integer(limit),
    offset = as.integer(offset)
  )
  if (!is.null(franchises)) variables$franchises <- as.list(franchises)
  if (!is.null(player_ids)) variables$playerIds <- as.list(player_ids)

  data <- pga_graphql_request("NewsArticles", variables)
  articles <- safe_pluck(data, "newsArticles", "articles")

  if (is.null(articles) || length(articles) == 0) {
    return(tibble())
  }

  tibble(
    id = vapply(articles, function(a) a$id %||% NA_character_, character(1)),
    headline = vapply(articles, function(a) a$headline %||% NA_character_, character(1)),
    teaser_headline = vapply(articles, function(a) a$teaserHeadline %||% NA_character_, character(1)),
    teaser_content = vapply(articles, function(a) a$teaserContent %||% NA_character_, character(1)),
    url = vapply(articles, function(a) a$url %||% NA_character_, character(1)),
    share_url = vapply(articles, function(a) a$shareURL %||% NA_character_, character(1)),
    publish_date = as.POSIXct(
      vapply(articles, function(a) a$publishDate %||% NA_real_, double(1)) / 1000,
      origin = "1970-01-01", tz = "UTC"
    ),
    update_date = as.POSIXct(
      vapply(articles, function(a) a$updateDate %||% NA_real_, double(1)) / 1000,
      origin = "1970-01-01", tz = "UTC"
    ),
    franchise = vapply(articles, function(a) a$franchise %||% NA_character_, character(1)),
    franchise_display_name = vapply(articles, function(a) a$franchiseDisplayName %||% NA_character_, character(1)),
    article_image = vapply(articles, function(a) a$articleImage %||% NA_character_, character(1)),
    author_first = vapply(articles, function(a) safe_pluck(a, "author", "firstName") %||% NA_character_, character(1)),
    author_last = vapply(articles, function(a) safe_pluck(a, "author", "lastName") %||% NA_character_, character(1)),
    is_live = vapply(articles, function(a) a$isLive %||% NA, logical(1)),
    ai_generated = vapply(articles, function(a) a$aiGenerated %||% NA, logical(1)),
    article_form_type = vapply(articles, function(a) a$articleFormType %||% NA_character_, character(1))
  )
}

#' Get news franchise/category list
#'
#' Returns available news categories for filtering with [pga_news()].
#'
#' @param tour Character. Tour code. Defaults to `"R"`.
#' @return A tibble with franchise and label columns.
#' @export
#' @examples
#' \dontrun{
#' pga_news_franchises()
#' }
pga_news_franchises <- function(tour = "R") {
  data <- pga_graphql_request(
    "NewsFranchises",
    list(tourCode = tour, allFranchises = FALSE)
  )

  franchises <- data$newsFranchises
  if (is.null(franchises) || length(franchises) == 0) {
    return(tibble())
  }

  if (is.data.frame(franchises)) {
    return(clean_names(as_tibble(franchises)))
  }

  tibble(
    franchise = vapply(franchises, function(f) f$franchise %||% NA_character_, character(1)),
    franchise_label = vapply(franchises, function(f) f$franchiseLabel %||% NA_character_, character(1))
  )
}
