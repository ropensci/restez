# LIBS
library(restez)
library(testthat)

# VARS
test_database_file <- 'test_database'
nrcrds <- 10  # how many fake records to test on?

# DATA
data("records")

# FUNCTIONS
clean <- function() {
  if (file.exists(test_database_file)) {
    unlink(test_database_file)
  }
}

# SETUP
df <- restez:::generate_dataframe(records = sample(records, size = nrcrds))
ids <- as.character(df[['accession']])
restez:::add_to_database(df = df, database = 'nucleotide',
                         filepath = test_database_file)

# RUNNING
context('Testing \'query-tools\'')
test_that('get_sequence_from_id() works', {
  id <- sample(ids, 1)
  sequence <- restez:::get_sequence_from_id(id = id,
                                            filepath = test_database_file)
  expect_true(grepl('[atcgn]*', sequence))
})
clean()