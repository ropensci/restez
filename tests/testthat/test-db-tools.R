# LIBS
library(restez)
library(testthat)
library(mockery)

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
  expect_true(file.exists(restez:::sql_path_get()))
})
test_that('search_gz() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  fp <- file.path(restez:::dwnld_path_get(), 'test.seq')
  record_text <- paste0(unlist(records), collapse = '\n')
  write(x = record_text, file = fp)
  R.utils::gzip(fp)
  fp_zip <- paste0(fp, ".gz")
  expect_true(
    search_gz(c("AC092025", "AC090116"), fp_zip)
  )
  expect_false(
    search_gz(c("AC0920254085dfash", "AC09011635t09248tgjaf"), fp_zip)
  )
})
test_that('search_gz() works inside db_create()', {
  restez:::setup()
  restez::restez_connect()
  on.exit(restez:::cleanup())
  fp <- file.path(restez:::dwnld_path_get(), 'test.seq')
  record_text <- paste0(unlist(records), collapse = '\n')
  write(x = record_text, file = fp)
  R.utils::gzip(fp)
  db_create(acc_filter = c("AC092025", "AC090116"), scan = TRUE)
  expect_true(file.exists(restez:::sql_path_get()))
  restez::restez_connect()
  expect_equal(
    sort(list_db_ids(n = NULL)),
    sort(c("AC092025", "AC090116"))
  )
  restez:::cleanup()
})
test_that('db_download() works', {
  setup()
  on.exit(cleanup())
  stub(db_download, "check_connection", TRUE)
  stub(db_download, "latest_genbank_release", 1000)
  stub(db_download, "latest_genbank_release_notes", NULL)
  stub(db_download, "identify_downloadable_files", mck_dwnldbl)
  stub(db_download, "restez_rl", "1")
  stub(db_download, "file_download", TRUE)
  expect_true(db_download())
})
test_that('db_delete() works', {
  setup()
  on.exit(cleanup())
  demo_db_create()
  db_delete(everything = FALSE)
  expect_false(file.exists(restez:::sql_path_get()))
  expect_true(file.exists(restez_path_get()))
  db_delete(everything = TRUE)
  expect_false(file.exists(file.path('test_db_fldr', 'restez')))
  expect_null(restez_path_get())
})
restez:::cleanup()
