# LIBS
library(restez)
library(testthat)

# VARS
test_filepath <- 'test_startup'

# FUNCTIONS
clean_up <- function() {
  if (dir.exists(test_filepath)) {
    unlink(test_filepath, recursive = TRUE)
  }
}

# RUNNING
clean_up()
context('Testing \'startup\'')
test_that('set_database_filepath() works', {
  dir.create(test_filepath)
  set_database_filepath(filepath = test_filepath)
  expect_true(getOption('restez_database_filepath') ==
                file.path(test_filepath, 'restez_database'))
  clean_up()
})
clean_up()
