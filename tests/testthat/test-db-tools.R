# LIBS
library(testthat)
library(mockery)

# VARS
nrcrds <- 5
data_d <- testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))
mck_dwnldbl <- data.frame(descripts = 'type1', seq_files = 'file1.seq',
                          filesizes = '100')

# RUNNING
context('Testing \'db-setup-tools\'')
cleanup()
test_that('demo_db_create() works', {
  setup()
  on.exit(cleanup())
  demo_db_create()
  restez_connect()
  sequence <- gb_sequence_get('demo_1')[[1]]
  expect_true(grepl(pattern = '[atcg]', x = sequence, ignore.case = TRUE))
})
test_that('db_create() works', {
  setup()
  on.exit(cleanup())
  fp <- file.path(dwnld_path_get(), 'test.seq')
  rndm_rcrds <- sample(records, nrcrds)
  record_text <- paste0(unlist(rndm_rcrds), collapse = '\n')
  write(x = record_text, file = fp)
  R.utils::gzip(fp)
  db_create()
  expect_error(db_create())
  expect_true(file.exists(sql_path_get()))
})
test_that('search_gz() works', {
  setup()
  on.exit(cleanup())
  fp <- file.path(dwnld_path_get(), 'test.seq')
  record_text <- paste0(unlist(records), collapse = '\n')
  write(x = record_text, file = fp)
  R.utils::gzip(fp)
  fp_zip <- paste0(fp, ".gz")
  skip_on_os("windows") # does not work on windows (no zgrep)
  expect_true(
    search_gz(c("AC092025", "AC090116"), fp_zip)
  )
  expect_false(
    search_gz(c("AC0920254085dfash", "AC09011635t09248tgjaf"), fp_zip)
  )
})
test_that('search_gz() works inside db_create()', {
  setup()
  restez_connect()
  on.exit(cleanup())
  fp <- file.path(dwnld_path_get(), 'test.seq')
  record_text <- paste0(unlist(records), collapse = '\n')
  write(x = record_text, file = fp)
  R.utils::gzip(fp)
  db_create(acc_filter = c("AC092025", "AC090116"), scan = TRUE)
  skip_on_os("windows") # does not work on windows (no zgrep)
  expect_true(file.exists(sql_path_get()))
  restez_connect()
  expect_equal(
    sort(list_db_ids(n = NULL)),
    sort(c("AC092025", "AC090116"))
  )
  cleanup()
})
test_that('search_gz() warning works', {
  setup()
  on.exit(cleanup())
  fp <- file.path(dwnld_path_get(), 'test.seq')
  record_text <- paste0(unlist(records), collapse = '\n')
  write(x = record_text, file = fp)
  R.utils::gzip(fp)
  fp_zip <- paste0(fp, ".gz")
  skip_on_os(c("mac", "linux", "solaris")) # only run on windows
  expect_warning(
    search_gz(c("AC092025", "AC090116"), fp_zip),
    "Cannot scan gzipped file without zgrep"
  )
})
test_that('db_download_intern() works', {
  setup()
  on.exit(cleanup())
  stub(db_download_intern, "check_connection", TRUE)
  stub(db_download_intern, "latest_genbank_release", 1000)
  stub(db_download_intern, "latest_genbank_release_notes", NULL)
  stub(db_download_intern, "identify_downloadable_files", mck_dwnldbl)
  stub(db_download_intern, "restez_rl", "1")
  stub(db_download_intern, "file_download", TRUE)
  expect_true(db_download_intern())
})
test_that('db_download() works', {
  setup()
  on.exit(cleanup())
  stub(db_download, "db_download_intern", TRUE)
  expect_true(db_download())
  expect_warning(
    db_download(overwrite = TRUE, max_tries = 2),
    "Setting 'overwrite' to FALSE is suggested with 'max_tries' > 1")
})
test_that('db_delete() works', {
  setup()
  on.exit(cleanup())
  demo_db_create()
  db_delete(everything = FALSE)
  expect_false(file.exists(sql_path_get()))
  expect_true(file.exists(restez_path_get()))
  db_delete(everything = TRUE)
  expect_false(file.exists(file.path('test_db_fldr', 'restez')))
  expect_null(restez_path_get())
})
test_that('ncbi_acc_get() works with fake data', {
  stub(ncbi_acc_get, "rentrez::entrez_search", list(count = 2))
  stub(ncbi_acc_get, "rentrez::entrez_fetch", "EU123060.1\nAB257475.1\n")
  expect_equal(
    ncbi_acc_get("Crepidomanes minutum"),
    c("EU123060", "AB257475")
  )
  expect_equal(
    ncbi_acc_get("Crepidomanes minutum", drop_ver = FALSE),
    c("EU123060.1", "AB257475.1")
  )
  stub(
    ncbi_acc_get,
    "rentrez::entrez_fetch", "EU123061.1\nEU123060.1\nAB257475.1\n")
  expect_error(ncbi_acc_get("Crepidomanes minutum"), "Number of accessions")
  stub(
    ncbi_acc_get,
    "rentrez::entrez_fetch", "EU123061.1\nEU123061.1\n")
  expect_error(
    ncbi_acc_get("Crepidomanes minutum"), "Number of unique accessions")
})
test_that('ncbi_acc_get() works with real data', {
  skip_if_offline()
  cmin_accs <- ncbi_acc_get("Crepidomanes minutum")
  expect_type(cmin_accs, "character")
})

cleanup()
