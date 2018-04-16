# LIBS
library(restez)
library(testthat)

# VARS
test_filepath <- 'test_database'
nrcrds <- 10  # how many fake records to test on?

# DATA
data("records")

# FUNCTIONS
clean <- function() {
  if (file.exists(test_filepath)) {
    unlink(test_filepath, recursive = TRUE)
  }
}

# SETUP
dir.create(test_filepath)
set_database_filepath(test_filepath)
df <- restez:::generate_dataframe(records = sample(records, size = nrcrds))
ids <- as.character(df[['accession']])
restez:::add_to_database(df = df, database = 'nucleotide')

# RUNNING
context('Testing \'get-tools\'')
test_that('get_sequence() works', {
  id <- sample(ids, 1)
  sequence <- restez:::get_sequence(id = id)
  expect_true(grepl('[atcgn]*', sequence[[1]]))
})
test_that('list_db_ids() works', {
  res <- restez:::list_db_ids(db = 'nucleotide')
  expect_true(all(ids %in% res))
})
clean()
