# Error occurs on a Windows machine.
# https://github.com/ropensci/restez/issues/14

monetdb_embedded_query2 <- function(conn, query, execute=TRUE, resultconvert=TRUE, int64=FALSE) {
  print('My function')
  if (!inherits(conn, MonetDBLite:::classname)) {
    stop("Invalid connection")
  }
  query <- as.character(query)
  if (length(query) != 1) {
    stop("Need a single query as parameter.")
  }
  if (!MonetDBLite:::monetdb_embedded_env$is_started) {
    stop("Call monetdb_embedded_startup() first")
  }
  if (MonetDBLite:::monetdb_embedded_env$started_dir != ":memory:" &&
      !dir.exists(file.path(MonetDBLite:::monetdb_embedded_env$started_dir, "bat"))) {
    stop("Someone killed all the BATs! Call Brigitte Bardot!")
  }
  execute <- as.logical(execute)
  if (length(execute) != 1) {
    stop("Need a single execute flag as parameter.")
  }
  resultconvert <- as.logical(resultconvert)
  if (length(resultconvert) != 1) {
    stop("Need a single resultconvert flag as parameter.")
  }
  int64 <- as.logical(int64)
  if (length(resultconvert) != 1) {
    stop("Need a single int64 flag as parameter.")
  }
  if (int64 && !requireNamespace("bit64", quietly = TRUE)) {
    stop("Need bit64 package for integer64 support")
  }
  
  # make sure the query is terminated
  query <- paste(query, "\n;", sep="")
  res <- .Call(MonetDBLite:::monetdb_query_R, conn, query, execute, resultconvert, interactive() &&
                 getOption("monetdb.progress", FALSE), int64)
  resp <- list()
  if (is.character(res)) { # error
    resp$type <- "!" # MSG_MESSAGE
    res <- iconv(res, to = 'UTF-8')
    resp$message <- gsub("\n", " ", res, fixed=TRUE)
  }
  if (is.numeric(res)) { # no result set, but successful
    resp$type <- 2 # Q_UPDATE
    resp$rows <- res
  }
  if (is.list(res)) {
    resp$type <- 1 # Q_TABLE
    if ("__prepare" %in% names(attributes(res))) {
      resp$type <- Q_PREPARE
      resp$prepare = attr(res, "__prepare")
      attr(res, "__prepare") <- NULL
    }
    attr(res, "row.names") <- c(NA_integer_, as.integer(-1 * attr(res, "__rows")))
    class(res) <- "data.frame"
    names(res) <- gsub("\\", "", names(res), fixed=T)
    resp$tuples <- res
  }
  resp
}

library(restez)
# devtools::install_github('ropensci/restez')
dir.create('GenBank_animals')
restez_path_set('GenBank_animals')
db_download(preselection = '12 14 15 11 9')
db_create()

assignInNamespace('monetdb_embedded_query', monetdb_embedded_query2, ns = 'MonetDBLite')

restez_connect() 
dpth <- restez:::dwnld_path_get()
seq_files <- list.files(dpth, pattern = '.seq.gz')
for (seq_file in seq_files) {
  print(seq_file)
  flpth <- file.path(dpth, seq_file)
  records <- restez:::flatfile_read(flpth = flpth)
  df <- restez:::gb_df_generate(records = records, min_length = 0, max_length = NULL)
  connection <- restez:::connection_get()
  if (!restez_ready()) {
    DBI::dbBegin(conn = connection)
    DBI::dbSendQuery(conn = connection, "CREATE TABLE nucleotide (accession VARCHAR(20), version INT, organism VARCHAR(100), raw_definition BLOB, raw_sequence BLOB, raw_record BLOB, PRIMARY KEY (accession))")
    DBI::dbCommit(conn = connection)
  }
  DBI::dbWriteTable(conn = connection, name = "nucleotide", value = df, append = TRUE)
}
