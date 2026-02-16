# utils.R
# Internal helper function - not exported
## Validates numerical input
### Prevents need to repeat same checks in every function

validate_num <- function(x, arg_name = 'x') {
  
  # Flag inputs that are not numeric
  if (!is.numeric(x)) {
    stop(
      sprintf("`%s` must be a numeric vector, not a <%s>.", arg_name, class(x)[[1]]),
      call. = FALSE
    )
  }
  
  # Flag inputs that are NULL
  if (length(x) == 0L) {
    stop(
      sprintf("`%s` must not be an empty vector.", arg_name),
      call. = FALSE
    )
  }
  
  invisible(NULL)
}
