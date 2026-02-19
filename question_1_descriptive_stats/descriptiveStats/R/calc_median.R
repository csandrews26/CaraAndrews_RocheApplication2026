#' Calculate median
#'
#' @description Returns median value of a numerical vector, with control over
#'   how `NA` values are handled.
#'
#' @param x A numeric vector. Must not be empty.
#' @param na.rm Logical. Should missing values be removed before calculation?
#'   Defaults to `FALSE`.
#'
#' @return A single numeric value representing the median of `x`.
#'
#' @author Cara Andrews
#'
#' @export
#' 
#' @examples
#' calc_median(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))  # 4.5
#' calc_median(c(1, 2, NA, 4), na.rm = TRUE) # 2
#' 
#' @importFrom stats median

# Function to calculate median
calc_median <- function(x, na.rm = FALSE) {
  # validate input
  validate_num(x)
  # calculate median using {stats}
  median(x, na.rm = na.rm)
}
