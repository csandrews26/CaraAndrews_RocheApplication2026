#' Calculate Interquartile Range (IQR)
#'
#' @description Returns the interquartile range, defined as Q3-Q1 (first quartile 
#'   subtracted from third), of a numeric vector. A measure of statistical dispersion.
#'
#' @param x A numeric vector. Must not be empty.
#' @param na.rm Logical. Should missing values be removed before calculation?
#'   Defaults to `FALSE`. If `FALSE` and `x` contains `NA`, returns `NA`.
#'
#' @return The numeric value representing the IQR of `x`.
#'
#' @author Cara Andrews
#'
#' @export
#' 
#' @examples
#' calc_iqr(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))  # 3
#' calc_iqr(c(1, 2, NA, 4), na.rm = TRUE)      # 2
#'  
#' @importFrom stats quantile


# Function to calculate first quartile
calc_iqr <- function(x, na.rm = FALSE) {
  # Validate input
  validate_num(x)
  # Flags inputs that have NA values and na.rm = FALSE
  # Flags inputs that have NA values and na.rm = FALSE
  if (anyNA(x) & na.rm == FALSE) {
    stop(
      "Input contains NA values, IQR cannot be calculated",
      call. = FALSE
    )
  }
  # Calculate IQR using functions defined in calc_q3.R and calc_q1.R
  result <- calc_q3(x, na.rm = na.rm) - calc_q1(x, na.rm = na.rm)
  
  result
}
