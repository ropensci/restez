# LIBS
library(restez)
library(testthat)

# VARS
test_records_file <- 'test_records.txt'
test_db_fldr <- 'test_db_fldr'
nrcrds <- 3  # how many fake records to test on?
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

# FUNCTIONS
write_fake_records <- function(n=nrcrds) {
  records_text <- ''
  for (i in 1:n) {
    records_text <- paste0(records_text,
                           restez:::mock_rec(i), '\n')
  }
  cat(records_text, file = test_records_file)
  NULL
}
clean <- function() {
  if (file.exists(test_records_file)) {
    file.remove(test_records_file)
  }
  if (dir.exists(test_db_fldr)) {
    unlink(test_db_fldr, recursive = TRUE)
  }
}

# RUNNING
context('Testing \'setup-tools\'')
clean()
test_that('flatfile_read() works', {
  write_fake_records(n = nrcrds)
  records <- restez:::flatfile_read(filepath = test_records_file)
  expect_true(length(records) == nrcrds)
  clean()
})
test_that('gb_df_create() works', {
  fake_data <- rep('', nrcrds)
  df <- restez:::gb_df_create(accessions = fake_data,
                              versions = fake_data,
                              organisms = fake_data,
                              definitions = fake_data,
                              sequences = fake_data,
                              records = fake_data)
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
  dir.create(test_db_fldr)
  restez_path_set(test_db_fldr)
  df <- restez:::gb_df_generate(records = sample(records, size = nrcrds))
  restez:::gb_sql_add(df = df, database = 'nucleotide')
  expect_true(file.exists(restez:::sql_path_get()))
  clean()
})
clean()
