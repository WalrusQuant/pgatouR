# API constants
.pga_graphql_url <- "https://orchestrator.pgatour.com/graphql"
.pga_rest_url <- "https://data-api.pgatour.com"
.pga_api_key_default <- "da2-gsrx5bibzbb4njvhl7t37wqyl4"

# Cache environment for query strings
.pga_cache <- new.env(parent = emptyenv())

# Resolve the API key, preferring the PGA_API_KEY env var so users can swap
# keys without reinstalling if the bundled frontend key rotates.
pga_api_key <- function() {
  key <- Sys.getenv("PGA_API_KEY", unset = "")
  if (nzchar(key)) key else .pga_api_key_default
}

# Treat the listed HTTP statuses as transient and worth retrying.
.pga_is_transient <- function(resp) {
  httr2::resp_status(resp) %in% c(408, 429, 500, 502, 503, 504)
}

# Parse a response body as JSON, but surface a clean error that names the
# operation when the body is not actually JSON (e.g. a CDN-served HTML 5xx).
pga_parse_json <- function(resp, context) {
  tryCatch(
    resp_body_json(resp),
    error = function(e) {
      cli_abort(c(
        "PGA Tour API returned a non-JSON response.",
        "i" = "Context: {.val {context}}",
        "i" = "Status: {resp_status(resp)}",
        "x" = conditionMessage(e)
      ))
    }
  )
}

#' Read a GraphQL query from inst/graphql/
#' @param operation_name Character. The operation name (file stem).
#' @return Character. The query string.
#' @noRd
pga_read_query <- function(operation_name) {
  cache_key <- paste0("query_", operation_name)
  if (exists(cache_key, envir = .pga_cache)) {
    return(get(cache_key, envir = .pga_cache))
  }

  path <- system.file(
    "graphql", paste0(operation_name, ".graphql"),
    package = "pgatouR"
  )

  if (path == "") {
    cli_abort("GraphQL query file not found: {.val {operation_name}}.graphql")
  }

  query <- paste(readLines(path, warn = FALSE), collapse = "\n")
  assign(cache_key, query, envir = .pga_cache)
  query
}

#' Make a GraphQL request to the PGA Tour API
#' @param operation_name Character. The GraphQL operation name.
#' @param variables Named list. Query variables.
#' @return Parsed response data (the contents of `data` in the GraphQL response).
#' @noRd
pga_graphql_request <- function(operation_name, variables = list()) {
  query <- pga_read_query(operation_name)

  resp <- request(.pga_graphql_url) |>
    req_user_agent("pgatouR R package (https://github.com/WalrusQuant/pgatouR)") |>
    req_headers(
      `Content-Type` = "application/json",
      Accept = "application/graphql-response+json, application/json",
      `x-api-key` = pga_api_key(),
      `x-pgat-platform` = "web",
      Origin = "https://www.pgatour.com",
      Referer = "https://www.pgatour.com/"
    ) |>
    req_body_json(list(
      query = query,
      variables = variables,
      operationName = operation_name
    )) |>
    req_throttle(rate = 10) |>
    req_timeout(30) |>
    req_retry(max_tries = 3, is_transient = .pga_is_transient) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  status <- resp_status(resp)
  if (status >= 400) {
    cli_abort(c(
      "PGA Tour API request failed with HTTP {status}.",
      "i" = "Operation: {.val {operation_name}}"
    ))
  }

  body <- pga_parse_json(resp, operation_name)

  if (!is.null(body$errors)) {
    msg <- paste(vapply(body$errors, function(e) e$message, character(1)),
                 collapse = "; ")
    cli_abort(c(
      "PGA Tour GraphQL error: {msg}",
      "i" = "Operation: {.val {operation_name}}"
    ))
  }

  body$data
}

#' Make a REST request to the PGA Tour data API
#' @param path Character. URL path to append.
#' @return Parsed JSON as a list.
#' @noRd
pga_rest_request <- function(path) {
  resp <- request(.pga_rest_url) |>
    req_url_path_append(path) |>
    req_user_agent("pgatouR R package (https://github.com/WalrusQuant/pgatouR)") |>
    req_throttle(rate = 10) |>
    req_timeout(30) |>
    req_retry(max_tries = 3, is_transient = .pga_is_transient) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  status <- resp_status(resp)
  if (status >= 400) {
    cli_abort(c(
      "PGA Tour REST API request failed with HTTP {status}.",
      "i" = "Path: {.val {path}}"
    ))
  }

  pga_parse_json(resp, path)
}
