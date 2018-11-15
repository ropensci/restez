# LIBS
library(restez)
library(testthat)

# VARS
nrcrds <- 50  # how many fake records to test on?
data_d <- restez:::testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))

# FUNCTIONS
write_fake_records <- function(n=nrcrds) {
  records_text <- ''
  for (i in 1:n) {
    records_text <- paste0(records_text,
                           restez:::mock_rec(i, sequence = 'atcg'), '\n')
  }
  cat(records_text, file = 'test_records.txt')
  NULL
}

# RUNNING
context('Testing \'setup-tools\'')
restez:::cleanup()
test_that('gb_build() works', {
  res <- with_mock(
    `restez::quiet_connect` = function() NULL,
    `restez::flatfile_read` = function(...) NULL,
    `restez::gb_df_generate` = function() NULL,
    `restez::gb_sql_add` = function() NULL,
    `restez::add_rcrd_log` = function() NULL,
    restez:::gb_build(dpth = NULL, seq_files = 1:10, max_length = NULL,
                      min_length = NULL)
  )
  expect_true(res)
  res <- with_mock(
    `restez::quiet_connect` = function() NULL,
    `restez::flatfile_read` = function(...) NULL,
    `restez::gb_df_generate` = function() NULL,
    `restez::gb_sql_add` = function() NULL,
    `restez::add_rcrd_log` = function() NULL,
    restez:::gb_build(dpth = NULL, seq_files = NULL, max_length = NULL,
                      min_length = NULL)
  )
  expect_false(res)
})
test_that('flatfile_read() works', {
  write_fake_records(n = nrcrds)
  records <- restez:::flatfile_read(flpth = 'test_records.txt')
  expect_true(length(records) == nrcrds)
  restez:::cleanup()
})
test_that('gb_df_create() works', {
  fake_data <- rep('', nrcrds)
  df <- restez:::gb_df_create(accessions = fake_data, versions = fake_data,
                              organisms = fake_data, definitions = fake_data,
                              sequences = fake_data, records = fake_data)
  expect_true(nrow(df) == nrcrds)
})
test_that('gb_df_generate() works', {
  df <- restez:::gb_df_generate(records = sample(records, size = 3))
  expect_true(nrow(df) == 3)
  expctd_clnms <- c("accession", "version", "organism", "raw_definition",
                    "raw_sequence", "raw_record")
  expect_true(all(colnames(df) %in% expctd_clnms))
})
test_that('gb_sql_add() works', {
  restez:::setup()
  restez::restez_connect()
  on.exit(restez:::cleanup())
  df <- restez:::gb_df_generate(records = sample(records, size = 3))
  restez:::gb_sql_add(df = df)
  expect_true(file.exists(restez:::sql_path_get()))
})
restez:::cleanup()
