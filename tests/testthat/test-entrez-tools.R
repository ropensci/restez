# LIBS
library(testthat)

# VARS
nrcrds <- 10  # how many fake records to test on?
data_d <- testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))

# SETUP
cleanup()
setup()
df <- gb_df_generate(records = sample(records, size = nrcrds))
df <- gb_df_generate(records = records)
ids <- as.character(df[['accession']])
gb_sql_add(df = df)

# RUNNING
context('Testing \'entrez-tools\'')
test_that('entrez_fasta_get() works', {
  # rentrez_fastas <- rentrez::entrez_fetch(id = id, db = 'nucleotide',
  #                                         rettype = 'fasta')
  res <- entrez_fasta_get(id = sample(ids, 2))
  expect_true(inherits(res, 'character'))
  mtch_obj <- gregexpr(pattern = '\n\n', text = res)[[1]]
  expect_true(length(mtch_obj) == 2)
  expect_true(grepl(pattern = '^>.*', x = res))
  # if not in local, should search internet
  local_mocked_bindings(
    entrez_fetch_wrap = function(...) '>notanid\nATCG\n\n'
  )
  res <- entrez_fasta_get(id = 'notanid')
  expect_true(grepl('>notanid', res))
  # should be able to handle mixture
  res <- entrez_fasta_get(id = c(sample(ids, 2), 'notanid'))
  expect_true(grepl('>notanid', res))
  mtch_obj <- gregexpr(pattern = '\n\n', text = res)[[1]]
  expect_true(length(mtch_obj) == 3)
})
test_that('entrez_gb_get() works', {
  # id <- c('S71333', 'AY952423')
  # rentrez_records <- rentrez::entrez_fetch(id = id, db = 'nucleotide',
  #                                          rettype = 'gb')
  id <- sample(ids, 2)
  res <- entrez_gb_get(id = id, db = 'nucleotide',
                                rettype = 'gb')
  # res == rentrez_records
  expect_true(inherits(res, 'character'))
  mtch_obj <- gregexpr(pattern = '\n\n', text = res)[[1]]
  expect_true(length(mtch_obj) == 2)
  expect_true(grepl(pattern = 'LOCUS', x = res))
  # if not in local, should search internet
  local_mocked_bindings(
    entrez_fetch_wrap = function(...) 'LOCUS notanid\n//\n\n'
  )
  res <- entrez_gb_get(id = 'notanid')
  expect_true(grepl('notanid', res))
  # should be able to handle mixture
  res <- entrez_gb_get(id = c(sample(ids, 2), 'notanid'))
  expect_true(grepl('notanid', res))
  mtch_obj <- gregexpr(pattern = 'LOCUS', text = res)[[1]]
  expect_true(length(mtch_obj) == 3)
})
cleanup()
