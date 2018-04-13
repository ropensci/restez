# LIBS
library(restez)
library(testthat)

# VARS
test_dr <- 'test'

# FUNCTIONS
clean_up <- function() {
  if (dir.exists(test_dr)) {
    unlink(test_dr)
  }
}

# RUNNING
clean_up()
context('Testing \'startup\'')
test_that('set_database_filepath() works', {
  set_database_filepath(filepath = test_dr)
  expect_true(getOption('restez_database_filepath') == test_dr)
  expect_true(dir.exists(test_dr))
  clean_up()
})
clean_up()
