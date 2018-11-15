# LIBS
library(restez)
library(testthat)

# RUNNING
context('Testing \'callr-tools\'')
test_that('custom_download2() works', {
  with_mock(
    `restez:::custom_download` = function(...) NULL,
    expect_null(restez:::custom_download2(url = '', destfile = ''))
  )
})
test_that('gb_build2() works', {
  with_mock(
    `restez:::gb_build` = function(...) NULL,
    expect_null(restez:::gb_build2(dpth = NULL, seq_files = NULL,
                                   max_length = NULL, min_length = NULL))
  )
})