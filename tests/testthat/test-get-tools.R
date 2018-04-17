# LIBS
library(restez)
library(testthat)

# VARS
test_filepath <- 'test_get'
nrcrds <- 10  # how many fake records to test on?
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
clean <- function() {
  if (dir.exists(test_filepath)) {
    unlink(test_filepath, recursive = TRUE)
  }
}

# SETUP
dir.create(test_filepath)
set_restez_path(filepath = test_filepath)
df <- restez:::generate_dataframe(records = sample(records, size = nrcrds))
ids <- as.character(df[['accession']])
restez:::add_to_database(df = df, database = 'nucleotide')

# RUNNING
context('Testing \'get-tools\'')
test_that('get_sequence() works', {
  id <- sample(ids, 1)
  sequence <- get_sequence(id = id)
  expect_true(grepl('[atcgn]*', sequence[[1]]))
})
test_that('list_db_ids() works', {
  res <- restez:::list_db_ids(db = 'nucleotide')
  expect_true(all(ids %in% res))
})
clean()
