# Test code for calc_mode.R

## Returns correct value for standard input ----
test_that("calc_mode returns correct value for standard input", {
  expect_equal(calc_mode(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 5)
})

## Returns NA when NA present and na.rm = FALSE ----
test_that("calc_mode returns NA when NA present and na.rm = FALSE", {
  expect_equal(calc_mode(c(1, 2, NA)), NA_real_)
})

## Returns correct value when NA present and na.rm = FALSE ----
test_that("calc_mode returns NA when NA present and na.rm = FALSE", {
  expect_equal(calc_mode(c(1, 2, NA, 3, 4, 4, 5)), 4)
})

## Returns NA, when NA value removed (na.rm = TRUE), and all freq = 1 ----
test_that("calc_mode removes NA when na.rm = TRUE", {
  expect_equal(calc_mode(c(1, 2, NA, 3), na.rm = TRUE), NA_real_)
})

## Returns correct value, when NA value removed (na.rm = TRUE) ----
test_that("calc_mode removes NA when na.rm = TRUE", {
  expect_equal(calc_mode(c(1, 2, 3, NA, 3), na.rm = TRUE), 3)
})

## Returns correct error message when there's a non-numeric input ----
test_that("calc_mode errors on non-numeric input", {
  expect_error(calc_mode(c("a", "b")), "must be a numeric vector")
})

## Returns correct error message when the vector input us empty ----
test_that("calc_mode errors on empty vector", {
  expect_error(calc_mode(numeric(0)), "must not be an empty vector")
})