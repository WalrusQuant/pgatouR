# API constants
.pga_graphql_url <- "https://orchestrator.pgatour.com/graphql"
.pga_rest_url <- "https://data-api.pgatour.com"
.pga_api_key <- "da2-gsrx5bibzbb4njvhl7t37wqyl4"

# Cache environment for query strings
.pga_cache <- new.env(parent = emptyenv())

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
      `x-api-key` = .pga_api_key,
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
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  status <- resp_status(resp)
  if (status >= 400) {
    cli_abort(c(
      "PGA Tour API request failed with HTTP {status}.",
      "i" = "Operation: {.val {operation_name}}"
    ))
  }

  body <- resp_body_json(resp)

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
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  status <- resp_status(resp)
  if (status >= 400) {
    cli_abort("PGA Tour REST API request failed with HTTP {status}.")
  }

  resp_body_json(resp)
}
