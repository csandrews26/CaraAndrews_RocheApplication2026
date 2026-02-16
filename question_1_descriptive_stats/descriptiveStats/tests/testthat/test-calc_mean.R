# Test code for calc_mean.R

## Returns correct value for standard input ----
test_that("calc_mean returns correct value for standard input", {
  expect_equal(calc_mean(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 4.3)
})

## Returns NA when NA present and na.rm = FALSE ----
test_that("calc_mean returns NA when NA present and na.rm = FALSE", {
  expect_equal(calc_mean(c(1, 2, NA)), NA_real_)
})

## Returns correct value, by removing NA value when na.rm = TRUE ----
test_that("calc_mean removes NA when na.rm = TRUE", {
  expect_equal(calc_mean(c(1, 2, NA, 3), na.rm = TRUE), 2)
})

## Returns correct error message when there's a non-numeric input ----
test_that("calc_mean errors on non-numeric input", {
  expect_error(calc_mean(c("a", "b")), "must be a numeric vector")
})

## Returns correct error message when the vector input us empty ----
test_that("calc_mean errors on empty vector", {
  expect_error(calc_mean(numeric(0)), "must not be an empty vector")
})