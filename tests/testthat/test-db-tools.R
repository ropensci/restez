# LIBS
library(restez)
library(testthat)

# VARS
nrcrds <- 5
data_d <- restez:::testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))
mck_dwnldbl <- data.frame(descripts = 'type1', seq_files = 'file1.seq',
                          filesizes = '100')

# RUNNING
context('Testing \'db-setup-tools\'')
restez:::cleanup()
test_that('demo_db_create() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  demo_db_create()
  restez_connect()
  sequence <- gb_sequence_get('demo_1')[[1]]
  expect_true(grepl(pattern = '[atcg]', x = sequence, ignore.case = TRUE))
})
test_that('db_create() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  fp <- file.path(restez:::dwnld_path_get(), 'test.seq')
  rndm_rcrds <- sample(records, nrcrds)
  record_text <- paste0(unlist(rndm_rcrds), collapse = '\n')
  write(x = record_text, file = fp)
  R.utils::gzip(fp)
  db_create()
  expect_error(db_create())
  expect_true(dir.exists(restez:::sql_path_get()))
})
test_that('db_download() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  res <- with_mock(
    `restez:::check_connection` = function() TRUE,
    `restez:::latest_genbank_release` = function() 255,
    `restez:::latest_genbank_release_notes` = function() NULL,
    `restez:::identify_downloadable_files` = function() {
      mck_dwnldbl
      },
    `restez:::restez_rl` = function(prompt) '1',
    `restez:::file_download` = function(...) TRUE,
    restez:::db_download()
  )
  expect_true(res)
})
test_that('db_delete() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  demo_db_create()
  db_delete(everything = FALSE)
  expect_false(file.exists(restez:::sql_path_get()))
  expect_true(file.exists(restez_path_get()))
  db_delete(everything = TRUE)
  expect_false(file.exists(file.path('test_db_fldr', 'restez')))
  expect_null(restez_path_get())
})
restez:::cleanup()
