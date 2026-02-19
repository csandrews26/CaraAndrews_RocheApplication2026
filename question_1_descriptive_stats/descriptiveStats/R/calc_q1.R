#' Calculate first quartile (Q1)
#'
#' @description Returns the 25th percentile (first quartile) of a numeric vector.
#'
#' @param x A numeric vector. Must not be empty.
#' @param na.rm Logical. Should missing values be removed before calculation?
#'   Defaults to `FALSE`. If `FALSE` and `x` contains `NA`, returns `NA`.
#'
#' @return A single numeric value representing the first quartile of `x`.
#'
#' @author Cara Andrews
#'
#' @export
#' 
#' @examples
#' calc_q1(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))  # 2.25
#' calc_q1(c(1, 2, NA, 4), na.rm = TRUE)      # 1.5
#' 
#' @importFrom stats quantile


# Function to calculate first quartile
calc_q1 <- function(x, na.rm = FALSE) {
  # Validate input
  validate_num(x)
  # Flags inputs that have NA values and na.rm = FALSE
  if (anyNA(x) & na.rm == FALSE) {
    stop(
      "Input contains NA values, Q1 cannot be calculated",
      call. = FALSE
    )
  }
  # Calculate first quartile using {stats}
  result <- quantile(x, probs = 0.25, na.rm = na.rm, names = FALSE)
  
  result
}
