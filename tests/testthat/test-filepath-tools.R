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
context('Testing \'filepath-tools\'')
test_that('set_restez_path() works', {
  dir.create(test_filepath)
  set_restez_path(filepath = test_filepath)
  expect_true(get_restez_path() ==
                file.path(test_filepath, 'restez'))
  clean_up()
})
clean_up()
