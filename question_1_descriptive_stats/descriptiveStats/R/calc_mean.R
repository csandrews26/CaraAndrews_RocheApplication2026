#' Calculate arithmetic mean
#'
#' @description Returns arithmetic mean of a numerical vector, with control over
#'   how `NA` values are handled.
#'
#' @param x A numeric vector. Must not be empty.
#' @param na.rm Logical. Should missing values be removed before calculation?
#'   Defaults to `FALSE`.
#'
#' @return A single numeric value representing the arithmetic mean of `x`.
#'
#' @author Cara Andrews
#'
#' @export
#' 
#' @examples
#' calc_mean(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))  # 4.3
#' calc_mean(c(1, 2, NA, 4), na.rm = TRUE) # 2.333333

# Function to calculate mean
calc_mean <- function(x, na.rm = FALSE) {
  # validate input
  validate_num(x)
  # calculate mean using base R
  mean(x, na.rm = na.rm)
}
