# LIBS
library(restez)
library(testthat)

# VARS
nrcrds <- 10  # how many fake records to test on?
wd <- getwd()
data_d <- restez:::testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))

# SETUP
restez:::cleanup()
restez:::setup()
restez_connect()
df <- restez:::gb_df_generate(records = sample(records, size = nrcrds))
ids <- as.character(df[['accession']])
restez:::gb_sql_add(df = df)

# RUNNING
context('Testing \'rentrez-wrappers\'')
test_that('entrez_fetch() works', {
  # TODO, what if an ID that is not in the local db is given?
  fasta_res <- entrez_fetch(db = 'nucleotide', id = sample(ids, 2),
                            rettype = 'fasta')
  gb_res <- entrez_fetch(db = 'nucleotide', id = sample(ids, 2),
                         rettype = 'gb')
  # xml is not supported, rentrez will be called
  res <- with_mock(
    `rentrez:::entrez_fetch` = function(...) TRUE,
    entrez_fetch(db = 'nucleotide', id = sample(ids, 2),
                 rettype = 'gb', retmode = 'xml')
  )
  expect_true(res)
})
restez:::cleanup()
