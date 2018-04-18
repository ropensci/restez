# LIBS
library(restez)
library(testthat)

# VARS
test_db_fldr <- 'test_db_fldr'
nrcrds <- 5
wd <- getwd()
if (grepl('testthat', wd)) {
  data_d <- file.path('data')
} else {
  # for running test at package level
  data_d <- file.path('tests', 'testthat',
                      'data')
}

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))
mck_dwnldbl <- data.frame(descripts='type1', seq_files='file1.seq')

# FUNCTIONS
clean <- function() {
  if (dir.exists(test_db_fldr)) {
    unlink(test_db_fldr, recursive = TRUE)
  }
}

# RUNNING
context('Testing \'setup\'')
clean()
test_that('create_demo_database() works', {
  dir.create(test_db_fldr)
  set_restez_path(test_db_fldr)
  create_demo_database()
  sequence <- get_sequence('demo_1')[[1]]
  expect_true(grepl(pattern = '[atcg]', x = sequence))
  clean()
})
test_that('create_database() works', {
  dir.create(test_db_fldr)
  set_restez_path(test_db_fldr)
  fp <- file.path(restez:::get_dwnld_path(), 'test.seq')
  rndm_rcrds <- sample(records, nrcrds)
  record_text <- paste0(unlist(rndm_rcrds), collapse = '\n')
  write(x = record_text, file = fp)
  R.utils::gzip(fp)
  create_database()
  expect_true(file.exists(restez:::get_sql_path()))
  clean()
})
test_that('download_genbank() works', {
  dir.create(test_db_fldr)
  set_restez_path(test_db_fldr)
  res <- with_mock(
    `restez:::check_connection` = function() TRUE,
    `restez:::identify_latest_genbank_release_notes` = function() 1,
    `RCurl::getURL` = function(url) '',
    `restez:::identify_downloadable_files` = function(release_notes) mck_dwnldbl,
    `restez:::restez_rl` = function(prompt) '1',
    `restez:::download_file` = function(...) TRUE,
    restez:::download_genbank()
  )
  expect_null(res)
  clean()
})
clean()
