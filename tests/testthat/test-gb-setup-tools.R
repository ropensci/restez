# LIBS
library(testthat)

# VARS
nrcrds <- 50  # how many fake records to test on?
data_d <- testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))

# FUNCTIONS
write_fake_records <- function(n=nrcrds) {
  records_text <- ''
  for (i in 1:n) {
    records_text <- paste0(records_text,
                           mock_rec(i, sequence = 'atcg'), '\n')
  }
  cat(records_text, file = 'test_records.txt')
  NULL
}

# RUNNING
context('Testing \'setup-tools\'')
cleanup()
test_that('gb_build() works', {
  local_mocked_bindings(
    flatfile_read = function(...) NULL
  )
  res <- gb_build(
    dpth = NULL, seq_files = 1:10, max_length = NULL, min_length = NULL)
  expect_true(res)
  res <- gb_build(
    dpth = NULL, seq_files = NULL, max_length = NULL, min_length = NULL)
  expect_false(res)
})
test_that('flatfile_read() works', {
  write_fake_records(n = nrcrds)
  records <- flatfile_read(flpth = 'test_records.txt')
  expect_true(length(records) == nrcrds)
  cleanup()
})
test_that('gb_df_create() works', {
  fake_data <- rep('', nrcrds)
  df <- gb_df_create(accessions = fake_data, versions = fake_data,
                              organisms = fake_data, definitions = fake_data,
                              sequences = fake_data, records = fake_data)
  expect_true(nrow(df) == nrcrds)
})
test_that('gb_df_generate() works', {
  df <- gb_df_generate(records = sample(records, size = 3))
  expect_true(nrow(df) == 3)
  expctd_clnms <- c("accession", "version", "organism", "raw_definition",
                    "raw_sequence", "raw_record")
  expect_true(all(colnames(df) %in% expctd_clnms))
})
test_that('gb_df_generate() can filter by accession', {
  accs_filter <- c("AC092025", "AC090116", "AC091644")
  df <- gb_df_generate(
    records = records,
    acc_filter = accs_filter)
  expect_equal(sort(accs_filter), sort(df$accession))
  expect_true(nrow(df) == 3)
  expctd_clnms <- c("accession", "version", "organism", "raw_definition",
                    "raw_sequence", "raw_record")
  expect_true(all(colnames(df) %in% expctd_clnms))
})
test_that('gb_sql_add() works', {
  setup()
  on.exit(cleanup())
  df <- gb_df_generate(records = sample(records, size = 3))
  gb_sql_add(df = df)
  expect_true(file.exists(sql_path_get()))
})
cleanup()
