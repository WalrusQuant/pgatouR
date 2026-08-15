# Helpers shared across the test suite.
#
# Fixtures are captured by data-raw/fixtures.R and stored as RDS files in
# tests/testthat/fixtures/. Tests mock pga_graphql_request and
# pga_rest_request via testthat::local_mocked_bindings, so no test hits the
# network.

read_fixture <- function(name) {
  path <- testthat::test_path("fixtures", paste0(name, ".rds"))
  readRDS(path)
}

# Mock the GraphQL transport for the duration of the calling test. The mock
# returns whatever fixture was passed in, regardless of the operation name or
# variables — tests that need to distinguish operations should set this up
# per-call.
mock_graphql <- function(fixture_name, env = parent.frame()) {
  fixture <- read_fixture(fixture_name)
  testthat::local_mocked_bindings(
    pga_graphql_request = function(operation_name, variables = list()) fixture,
    .env = env
  )
}

mock_rest <- function(fixture_name, env = parent.frame()) {
  fixture <- read_fixture(fixture_name)
  testthat::local_mocked_bindings(
    pga_rest_request = function(path) fixture,
    .env = env
  )
}

mock_config <- function(fixture_name, env = parent.frame()) {
  fixture <- read_fixture(fixture_name)
  testthat::local_mocked_bindings(
    pga_config_request = function(path) fixture,
    .env = env
  )
}

# Route GraphQL calls by operation name to multiple fixtures. Useful for
# multi-stat / multi-year tests where one R function makes several calls.
mock_graphql_router <- function(routes, env = parent.frame()) {
  testthat::local_mocked_bindings(
    pga_graphql_request = function(operation_name, variables = list()) {
      if (!operation_name %in% names(routes)) {
        stop("No mock fixture registered for operation: ", operation_name)
      }
      routes[[operation_name]]
    },
    .env = env
  )
}
