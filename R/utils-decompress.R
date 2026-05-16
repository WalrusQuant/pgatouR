#' Decompress a base64-encoded gzip payload from the PGA Tour API
#'
#' The PGA Tour's *Compressed GraphQL operations return their data as a
#' base64-encoded gzip JSON string. This helper undoes that transport so
#' callers can work with the parsed object.
#'
#' On malformed input (empty string, non-base64, invalid gzip, invalid JSON)
#' this raises a clear error that names the failure step rather than letting
#' the underlying C-level decompressor surface a cryptic message.
#'
#' @param payload Character scalar. Base64-encoded gzip JSON.
#' @return The parsed JSON value (typically a list/data.frame).
#' @noRd
pga_decompress <- function(payload) {
  if (!is.character(payload) || length(payload) != 1 || is.na(payload) ||
      !nzchar(payload)) {
    cli_abort("{.arg payload} must be a non-empty character scalar.")
  }

  raw_bytes <- tryCatch(
    base64_dec(payload),
    error = function(e) {
      cli_abort(c(
        "Failed to base64-decode payload.",
        "x" = conditionMessage(e)
      ))
    }
  )

  decompressed <- tryCatch(
    memDecompress(raw_bytes, type = "gzip"),
    error = function(e) {
      cli_abort(c(
        "Failed to gunzip decoded payload.",
        "x" = conditionMessage(e)
      ))
    }
  )

  tryCatch(
    fromJSON(rawToChar(decompressed), simplifyVector = TRUE),
    error = function(e) {
      cli_abort(c(
        "Failed to parse decompressed payload as JSON.",
        "x" = conditionMessage(e)
      ))
    }
  )
}
