# LIBS
library(restez)
library(testthat)

# VARS
nrcrds <- 10  # how many fake records to test on?
data_d <- restez:::testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))

# SETUP
restez:::cleanup()
restez:::setup()
restez_connect()
df <- restez:::gb_df_generate(records = sample(records, size = nrcrds))
df <- restez:::gb_df_generate(records = records)
ids <- as.character(df[['accession']])
restez:::gb_sql_add(df = df)

# RUNNING
context('Testing \'entrez-tools\'')
test_that('entrez_fasta_get() works', {
  # rentrez_fastas <- rentrez::entrez_fetch(id = id, db = 'nucleotide',
  #                                         rettype = 'fasta')
  res <- restez:::entrez_fasta_get(id = sample(ids, 2))
  expect_true(inherits(res, 'character'))
  mtch_obj <- gregexpr(pattern = '\n\n', text = res)[[1]]
  expect_true(length(mtch_obj) == 2)
  expect_true(grepl(pattern = '^>.*', x = res))
  # if not in local, should search internet
  res <- with_mock(
    `rentrez:::entrez_fetch` = function(...) '>notanid\nATCG\n\n',
    restez:::entrez_fasta_get(id = 'notanid')
  )
  expect_true(grepl('>notanid', res))
  # should be able to handle mixture
  res <- with_mock(
    `rentrez:::entrez_fetch` = function(...) '>notanid\nATCG\n\n',
    restez:::entrez_fasta_get(id = c(sample(ids, 2), 'notanid'))
  )
  expect_true(grepl('>notanid', res))
  mtch_obj <- gregexpr(pattern = '\n\n', text = res)[[1]]
  expect_true(length(mtch_obj) == 3)
})
test_that('entrez_gb_get() works', {
  # id <- c('S71333', 'AY952423')
  # rentrez_records <- rentrez::entrez_fetch(id = id, db = 'nucleotide',
  #                                          rettype = 'gb')
  id <- sample(ids, 2)
  res <- restez:::entrez_gb_get(id = id, db = 'nucleotide',
                                rettype = 'gb')
  # res == rentrez_records
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
restez:::cleanup()
