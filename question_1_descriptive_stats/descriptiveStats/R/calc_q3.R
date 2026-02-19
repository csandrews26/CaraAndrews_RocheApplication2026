#' Calculate third quartile (Q3)
#'
#' @description Returns the 75th percentile (third quartile) of a numeric vector.
#'
#' @param x A numeric vector. Must not be empty.
#' @param na.rm Logical. Should missing values be removed before calculation?
#'   Defaults to `FALSE`. If `FALSE` and `x` contains `NA`, returns `NA`.
#'
#' @return A single numeric value representing the third quartile of `x`.
#'
#' @author Cara Andrews
#'
#' @export
#' 
#' @examples
#' calc_q3(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))  # 5.25
#' calc_q3(c(1, 2, NA, 4), na.rm = TRUE)      # 3.5
#'
#' @importFrom stats quantile


# Function to calculate third quartile
calc_q3 <- function(x, na.rm = FALSE) {
  # Validate input
  validate_num(x)
  # Flags inputs that have NA values and na.rm = FALSE
  # Flags inputs that have NA values and na.rm = FALSE
  if (anyNA(x) & na.rm == FALSE) {
    stop(
      "Input contains NA values, Q3 cannot be calculated",
      call. = FALSE
    )
  }
  # Calculate third quartile using {stats}
  result <- quantile(x, probs = 0.75, na.rm = na.rm, names = FALSE)
  
  result
}
