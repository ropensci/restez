# LIBS
library(restez)
library(testthat)

# RUNNING
context('Testing \'biomartr-tools\'')
test_that('check_connection() works', {
  with_mock(
    `RCurl::getURL` = function(...) FALSE,
    expect_error(restez:::check_connection())
  )
  with_mock(
    `RCurl::getURL` = function(...) '',
    expect_true(restez:::check_connection())
  )
})
test_that('custom_download() works', {
  with_mock(
    `downloader::download` = function(...) TRUE,
    expect_null(restez:::custom_download())
  )
})
