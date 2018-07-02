# LIBS
library(restez)
library(testthat)

# VARS
nrcrds <- 5
data_d <- restez:::testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))
mck_dwnldbl <- data.frame(descripts = 'type1', seq_files = 'file1.seq')

# RUNNING
context('Testing \'setup\'')
restez:::cleanup()
test_that('demo_db_create() works', {
  dir.create('test_db_fldr')
  restez_path_set('test_db_fldr')
  demo_db_create()
  sequence <- gb_sequence_get('demo_1')[[1]]
  expect_true(grepl(pattern = '[atcg]', x = sequence))
  restez:::cleanup()
})
test_that('db_create() works', {
  dir.create('test_db_fldr')
  restez_path_set('test_db_fldr')
  fp <- file.path(restez:::dwnld_path_get(), 'test.seq')
  rndm_rcrds <- sample(records, nrcrds)
  record_text <- paste0(unlist(rndm_rcrds), collapse = '\n')
  write(x = record_text, file = fp)
  R.utils::gzip(fp)
  db_create()
  expect_true(file.exists(restez:::sql_path_get()))
  restez:::cleanup()
})
test_that('db_download() works', {
  dir.create('test_db_fldr')
  restez_path_set('test_db_fldr')
  res <- with_mock(
    `restez:::check_connection` = function() TRUE,
    `restez:::identify_latest_genbank_release_notes` = function() 1,
    `RCurl::getURL` = function(url) '',
    `restez:::identify_downloadable_files` = function(release_notes) {
      mck_dwnldbl
      },
    `restez:::restez_rl` = function(prompt) '1',
    `restez:::file_download` = function(...) TRUE,
    restez:::db_download()
  )
  expect_true(res)
  restez:::cleanup()
})
restez:::cleanup()
