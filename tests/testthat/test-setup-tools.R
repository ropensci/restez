# LIBS
library(restez)
library(testthat)

# VARS
test_file <- 'test_records.txt'
nrcrds <- 3  # how many fake records to test on?

# DATA
data("records")

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
  cat(records_text, file = test_file)
  NULL
}
clean <- function() {
  if (file.exists(test_file)) {
    file.remove(test_file)
  }
}

# RUNNING
context('Testing \'setup-tools\'')
clean()
test_that('setup_database() works', {
  NULL
})
test_that('read_records() works', {
  write_fake_records(n = nrcrds)
  records <- restez:::read_records(filepath = test_file)
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
clean()

