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
clean()
dir.create(test_filepath)
restez_path_set(filepath = test_filepath)
df <- restez:::gb_df_generate(records = sample(records, size = nrcrds))
ids <- as.character(df[['accession']])
restez:::gb_sql_add(df = df, database = 'nucleotide')

# RUNNING
context('Testing \'rentrez-wrappers\'')
test_that('entrez_fetch() works', {
  # TODO, what if an ID that is not in the local db is given?
  fasta_res <- entrez_fetch(db = 'nucleotide',
                            id = sample(ids, 2),
                            rettype = 'fasta')
  gb_res <- entrez_fetch(db = 'nucleotide',
                         id = sample(ids, 2),
                         rettype = 'gb')
  # xml is not supported, rentrez will be called
  res <- with_mock(
    `rentrez:::entrez_fetch` = function(...) TRUE,
    entrez_fetch(db = 'nucleotide',
                 id = sample(ids, 2),
                 rettype = 'gb', retmode = 'xml')
  )
  expect_true(res)
})
clean()
