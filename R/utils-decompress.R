#' Decompress a base64-encoded gzip payload from the PGA Tour API
#'
#' @param payload Character. Base64-encoded gzip string.
#' @return A parsed list from the decompressed JSON.
#' @noRd
pga_decompress <- function(payload) {
  raw_bytes <- base64_dec(payload)
  decompressed <- memDecompress(raw_bytes, type = "gzip")
  fromJSON(rawToChar(decompressed), simplifyVector = TRUE)
}
