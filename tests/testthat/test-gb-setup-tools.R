# LIBS
library(restez)
library(testthat)

# VARS
nrcrds <- 3  # how many fake records to test on?
data_d <- restez:::testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))

# FUNCTIONS
write_fake_records <- function(n=nrcrds) {
  records_text <- ''
  for (i in 1:n) {
    records_text <- paste0(records_text,
                           restez:::mock_rec(i), '\n')
  }
  cat(records_text, file = 'test_records.txt')
  NULL
}

# RUNNING
context('Testing \'setup-tools\'')
restez:::cleanup()
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
  df <- restez:::gb_df_generate(records = sample(records, size = nrcrds))
  expect_true(nrow(df) == nrcrds)
  expctd_clnms <- c("accession", "version", "organism", "raw_definition",
                    "raw_sequence", "raw_record")
  expect_true(all(colnames(df) %in% expctd_clnms))
})
test_that('gb_sql_add() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  df <- restez:::gb_df_generate(records = sample(records, size = nrcrds))
  restez:::gb_sql_add(df = df)
  expect_true(file.exists(restez:::sql_path_get()))
})
restez:::cleanup()
