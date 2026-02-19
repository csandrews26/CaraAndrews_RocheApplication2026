#' Calculate mode
#'
#' @description Returns the modal value(s) of a numerical vector, with control over
#'   how `NA` values are handled.
#'
#' @param x A numeric vector. Must not be empty.
#' @param na.rm Logical. Should missing values be removed before calculation?
#'   Defaults to `FALSE`.
#'
#' @return The numeric value(s) representing the mode of `x`. Returns all tied 
#'   values when more than one value shares the highest frequency. Returns `NA` 
#'   if every value appears exactly once (no mode exists).
#'
#' @author Cara Andrews
#'
#' @export
#' 
#' @examples
#' calc_mode(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))  # 5
#' calc_mode(c(1, 1, 2, 2, 3))                  # 1 2  (tie)
#' calc_mode(c(1, 2, 3, 4))                     # NA  (no mode)
#' calc_mode(c(1, 2, NA, NA), na.rm = FALSE)    # NA  (NA is modal)
#' calc_mode(c(1, 2, NA, NA), na.rm = TRUE)     # NA  (no mode after removal)

# Function to calculate mode
calc_mode <- function(x, na.rm = FALSE) {
  # Validate input
  validate_num(x)
  
  # Remove NA values when na.rm is TRUE
  if (na.rm) {
    x <- x[!is.na(x)]
    if (length(x) == 0L) return(NA_real_)
  }
  
  # Table to count frequency of each integer
  freq_table   <- table(x)
  max_freq     <- max(freq_table) # max frequency
  
  # Return NA when all integers appear once
  if (max_freq == 1L) return(NA_real_)
  
  # Returns numbers with highest frequency
  as.numeric(names(freq_table[freq_table == max_freq]))
}
