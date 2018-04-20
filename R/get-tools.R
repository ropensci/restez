#' @name query_sql
#' @title Query SQL
#' @description Generic query function for retrieving
#' data from the SQL database for the get functions.
#' @param nm character, column name
#' @param id character, sequence accession ID(s)
#' @return data.frame
#' @noRd
query_sql <- function(nm, id) {
  # reduce ids to accessions
  id <- sub(pattern = '\\.[0-9]+', replacement = '', x = id)
  qry_id <- paste0('(', paste0(paste0("'", id, "'"), collapse = ','), ')')
  qry <- paste0("SELECT accession,", nm,
                " FROM nucleotide WHERE accession in ", qry_id)
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = get_sql_path())
  on.exit(DBI::dbDisconnect(conn = connection))
  qry <- DBI::dbSendQuery(conn = connection, statement = qry)
  on.exit(expr = {
    DBI::dbClearResult(res = qry)
    DBI::dbDisconnect(conn = connection)
    })
  res <- DBI::dbFetch(res = qry)
  res
}

#' @name get_fasta
#' @title Get fasta
#' @family get
#' @description Get sequence and definition data
#' in FASTA format.
#' @param id character, sequence accession ID(s)
#' @return named vector of fasta sequences, if no results found NULL
#' @export
#' @example examples/get_fasta.R
get_fasta <- function(id) {
  seqs <- get_sequence(id = id)
  if (length(seqs) == 0) {
    return(NULL)
  }
  defs <- get_definition(id = id)
  fastas <- paste0('>', defs, '\n', seqs)
  names(fastas) <- names(defs)
  fastas
}

#' @name get_sequence
#' @title Get sequence
#' @family get
#' @description Return the sequence(s) for a record(s)
#' from the accession ID(s).
#' @param id character, sequence accession ID(s)
#' @return named vector of sequences, if no results found NULL
#' @export
#' @example examples/get_sequence.R
get_sequence <- function(id) {
  res <- query_sql(nm = 'raw_sequence', id = id)
  sqs <- lapply(res[['raw_sequence']], rawToChar)
  names(sqs) <- res[['accession']]
  unlist(sqs)
}

#' @name get_record
#' @title Get record
#' @family get
#' @description Return the entire GenBank record
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of records, if no results found NULL
#' @export
#' @example examples/get_record.R
get_record <- function(id) {
  res <- query_sql(nm = 'raw_record', id = id)
  rcs <- lapply(res[['raw_record']], rawToChar)
  names(rcs) <- res[['accession']]
  unlist(rcs)
}

#' @name get_definition
#' @title Get definition
#' @family get
#' @description Return the definition line
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of definitions, if no results found NULL
#' @export
#' @example examples/get_definition.R
get_definition <- function(id) {
  res <- query_sql(nm = 'raw_definition', id = id)
  dfs <- lapply(res[['raw_definition']], rawToChar)
  names(dfs) <- res[['accession']]
  unlist(dfs)
}

#' @name get_organism
#' @title Get organism
#' @family get
#' @description Return the organism name
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of definitions, if no results found NULL
#' @export
#' @example examples/get_organism.R
get_organism <- function(id) {
  res <- query_sql(nm = 'organism', id = id)
  if (nrow(res) == 0) {
    return(NULL)
  }
  ors <- res[['organism']]
  names(ors) <- res[['accession']]
  ors
}

#' @name get_version
#' @title Get version
#' @family get
#' @description Return the accession version
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of versions, if no results found NULL
#' @export
#' @example examples/get_version.R
get_version <- function(id) {
  res <- query_sql(nm = 'version', id = id)
  vrs <- res[['version']]
  names(vrs) <- res[['accession']]
  vrs
}

#' @name list_db_ids
#' @title List database IDs
#' @family get
#' @description Return a vector of all IDs in
#' a database.
#' @details Warning: can return very large vectors
#' for large databases.
#' @param db character, database name
#' @return vector of characters
#' @export
#' @example examples/list_db_ids.R
list_db_ids <- function(db = 'nucleotide') {
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = get_sql_path())
  if (db == 'nucleotide') {
    res <- DBI::dbGetQuery(conn = connection,
                           statement =
                             "SELECT accession from nucleotide")
  }
  on.exit(DBI::dbDisconnect(conn = connection))
  res[[1]]
}

#' @name is_in_db
#' @title Is in db
#' @family get
#' @description Determine whether an id(s)
#' is/are present in a database.
#' @param id character, sequence accession ID(s)
#' @param db character, database name
#' @return named vector of booleans
#' @export
#' @example examples/is_in_db.R
is_in_db <- function(id, db = 'nucleotide') {
  accssns <- sub(pattern = '\\.[0-9]+', replacement = '',
                 x = id)
  db_res <- query_sql(nm = 'version', id = id)
  res <- accssns %in% db_res[['accession']]
  names(res) <- id
  res
}
