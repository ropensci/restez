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
make_fake_record <- function(i) {
  paste0('LOCUS       i
DEFINITION  defintion
ACCESSION   information
VERSION     version
KEYWORDS    keyword
SOURCE      tissue, organism
ORGANISM    species name
REFERENCE   reference data
AUTHORS     all the authors
TITLE       title
JOURNAL     journal
FEATURES    features
ORIGIN      sequence
//')
}
write_fake_records <- function(n=nrcrds) {
  records_text <- ''
  for (i in 1:n) {
    records_text <- paste0(records_text,
                           make_fake_record(i), '\n')
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
test_that('read_records() works', {
  write_fake_records(n = nrcrds)
  records <- restez:::read_records(filepath = test_records_file)
  expect_true(length(records) == nrcrds)
  clean()
})
test_that('generate_dataframe() works', {
  df <- restez:::generate_dataframe(records = sample(records, size = nrcrds))
  expect_true(nrow(df) == nrcrds)
  expctd_clnms <- c("accession", "organism", "raw_definition",
                    "raw_sequence", "raw_record")
  expect_true(all(colnames(df) %in% expctd_clnms))
})
test_that('add_to_database() works', {
  dir.create(test_db_fldr)
  set_restez_path(test_db_fldr)
  df <- restez:::generate_dataframe(records = sample(records, size = nrcrds))
  restez:::add_to_database(df = df, database = 'nucleotide')
  expect_true(file.exists(restez:::get_sql_path()))
  clean()
})
clean()
