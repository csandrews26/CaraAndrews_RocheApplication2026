# Test code for calc_q1.R

## Returns correct value for standard input ----
test_that("calc_q1 returns correct value for standard input", {
  expect_equal(calc_q1(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 2.25)
})

## Returns NA when NA present and na.rm = FALSE ----
test_that("calc_q1 returns NA when NA present and na.rm = FALSE", {
  expect_error(calc_q1(c(1, 2, NA)), 
               "Input contains NA values, Q1 cannot be calculated")
})

## Returns NA, when NA value removed (na.rm = TRUE), and all freq = 1 ----
test_that("calc_q1 removes NA when na.rm = TRUE", {
  expect_equal(calc_q1(c(1, 2, NA, 3), na.rm = TRUE), 1.5)
})

## Returns correct error message when there's a non-numeric input ----
test_that("calc_q1 errors on non-numeric input", {
  expect_error(calc_q1(c("a", "b")), "must be a numeric vector")
})

## Returns correct error message when the vector input us empty ----
test_that("calc_q1 errors on empty vector", {
  expect_error(calc_q1(numeric(0)), "must not be an empty vector")
})