# LIBS
library(restez)
library(testthat)

# FUNCTIONS
mock_cmd_generate <- function(...) {
  # exit the R process straight away
  'q(save = "no")\n'
}

# RUNNING
context('Testing \'subprocess-tools\'')
test_that('custom_download2() works', {
  with_mock(
    `restez:::download_cmd_generate` = mock_cmd_generate,
    expect_null(restez:::custom_download2(url = '', destfile = ''))
  )
})
test_that('rhandle_generate() works', {
  handle <- restez:::rhandle_generate()
  expect_true(subprocess::process_state(handle = handle) == 'running')
  if (subprocess::process_exists(handle)) {
    subprocess::process_kill(handle = handle)
  } else {
    id <- as.character(handle$c_handle)
    stop(id)
  }
  expect_true(subprocess::process_state(handle = handle) == 'terminated')
})
test_that('download_cmd_generate() works', {
  cmd <- restez:::download_cmd_generate(url = 'url', destfile = 'destfile')
  expect_true(inherits(cmd, 'character'))
})
test_that('handle_run() works', {
  handle <- restez:::rhandle_generate()
  cmd <- mock_cmd_generate()
  expect_null(restez:::handle_run(handle = handle, cmd = cmd))
})
