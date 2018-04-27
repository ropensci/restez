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
context('Testing \'entrez-tools\'')
test_that('entrez_fasta_get() works', {
  res <- restez:::entrez_fasta_get(id = sample(ids, 2))
  expect_true(inherits(res, 'character'))
  mtch_obj <- gregexpr(pattern = '\n\n', text = res)[[1]]
  expect_true(length(mtch_obj) == 3)
  expect_true(grepl(pattern = '^>.*', x = res))
  # if not in local, should search internet
  res <- with_mock(
    `rentrez:::entrez_fetch` = function(...) '>notanid\natcg\n\n',
    restez:::entrez_fasta_get(id = 'notanid')
  )
  expect_true(grepl('>notanid', res))
  # should be able to handle mixture
  res <- with_mock(
    `rentrez:::entrez_fetch` = function(...) '>notanid\natcg\n\n',
    restez:::entrez_fasta_get(id = c(sample(ids, 2), 'notanid'))
  )
  expect_true(grepl('>notanid', res))
  mtch_obj <- gregexpr(pattern = '\n\n', text = res)[[1]]
  expect_true(length(mtch_obj) == 4)
})
test_that('entrez_gb_get() works', {
  res <- restez:::entrez_gb_get(id = sample(ids, 2))
  expect_true(inherits(res, 'character'))
  mtch_obj <- gregexpr(pattern = '\n\n', text = res)[[1]]
  expect_true(length(mtch_obj) == 2)
  expect_true(grepl(pattern = 'LOCUS', x = res))
  # if not in local, should search internet
  res <- with_mock(
    `rentrez:::entrez_fetch` = function(...) 'LOCUS notanid\n//\n\n',
    restez:::entrez_gb_get(id = 'notanid')
  )
  expect_true(grepl('notanid', res))
  # should be able to handle mixture
  res <- with_mock(
    `rentrez:::entrez_fetch` = function(...) 'LOCUS notanid\n//\n\n',
    restez:::entrez_gb_get(id = c(sample(ids, 2), 'notanid'))
  )
  expect_true(grepl('notanid', res))
  mtch_obj <- gregexpr(pattern = 'LOCUS', text = res)[[1]]
  expect_true(length(mtch_obj) == 3)
})
clean()
