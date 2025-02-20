#' @name gb_sql_query
#' @title Query the GenBank SQL
#' @description Generic query function for retrieving
#' data from the SQL database for the get functions.
#' @param nm character, column name
#' @param id character, sequence accession ID(s)
#' @return data.frame
#' @family private
gb_sql_query <- function(nm, id) {
  on.exit(restez_disconnect())
  # reduce ids to accessions
  id <- sub(pattern = '\\.[0-9]+', replacement = '', x = id)
  qry_id <- paste0('(', paste0(paste0("'", id, "'"), collapse = ','), ')')
  qry <- paste0("SELECT accession,", nm,
                " FROM nucleotide WHERE accession IN ", qry_id)
  # first close any connection if one exists
  restez_disconnect()
  restez_connect(read_only = TRUE)
  connection <- connection_get()
  qry_res <- DBI::dbSendQuery(conn = connection, statement = qry)
  on.exit(expr = {
    DBI::dbClearResult(res = qry_res)
  })
  res <- DBI::dbFetch(res = qry_res)
  restez_disconnect()
  res
}

#' @name gb_fasta_get
#' @title Get fasta from GenBank
#' @family get
#' @description Get sequence and definition data in FASTA format. Equivalent to
#' `rettype='fasta'` in [rentrez::entrez_fetch()].
#' @param id character, sequence accession ID(s)
#' @param width integer, maximum number of characters in a line
#' @return named vector of fasta sequences, if no results found NULL
#' @export
#' @example examples/gb_fasta_get.R
#' @seealso [ncbi_acc_get()]
gb_fasta_get <- function(id, width=70) {
  # TODO: separate the fasta conversion into a new function and
  #  share with phylotaR
  res <- gb_sql_query(nm = 'raw_definition,raw_sequence,version', id = id)
  cnvrt <- function(i) {
    sq <- res[i, 'raw_sequence'][[1]]
    sq <- extract_clean_sequence(sq)
    def <- res[i, 'raw_definition'][[1]]
    n <- nchar(sq)
    if (n > width) {
      slices <- c(seq(from = 1, to = nchar(sq), by = width), nchar(sq) + 1)
      sq <- vapply(X = 2:length(slices), function(x) {
        substr(x = sq, start = slices[x - 1], stop = slices[x] - 1)
      }, character(1))
      sq <- paste0(sq, collapse = '\n')
    }
    paste0('>', res[i, 'accession'], '.', res[i, 'version'], ' ',
           def, '\n', sq, '\n\n')
  }
  if (nrow(res) == 0) {
    return(NULL)
  }
  fasta <- vapply(seq_len(nrow(res)), cnvrt, character(1))
  names(fasta) <- res[['accession']]
  fasta
}

#' @name gb_sequence_get
#' @title Get sequence from GenBank
#' @family get
#' @description Return the sequence(s) for a record(s)
#' from the accession ID(s).
#' @details For more information about the `dnabin` format, see [ape::DNAbin()].
#' @param id character, sequence accession ID(s)
#' @param dnabin Logical vector of length 1; should the sequences
#' be returned using the bit-level coding scheme of the ape package?
#' Default FALSE.
#' @return named vector of sequences, if no results found NULL
#' @export
#' @example examples/gb_sequence_get.R
#' @seealso [ncbi_acc_get()]
gb_sequence_get <- function(id, dnabin = FALSE) {

  assertthat::assert_that(assertthat::is.flag(dnabin))
  assertthat::assert_that(is.character(id))

  res <- gb_sql_query(nm = 'raw_sequence', id = id)
  sqs <- res[['raw_sequence']]
  sqs <- lapply(sqs, extract_clean_sequence)
  names(sqs) <- res[['accession']]
  sqs <- unlist(sqs)

  # Sort order of output to match id
  order <- match(names(sqs), id, nomatch = NA_integer_)
  order <- order[!is.na(order)]
  sqs <- sqs[order]

  if (isTRUE(dnabin)) {
    sq_names <- names(sqs)
    sqs <- ape::as.DNAbin(strsplit(sqs, ""))
    names(sqs) <- sq_names
  }

  return(sqs)

}

#' @name gb_record_get
#' @title Get record from GenBank
#' @family get
#' @description Return the entire GenBank record for an accession ID.
#' Equivalent to `rettype='gb'` in [rentrez::entrez_fetch()].
#' @param id character, sequence accession ID(s)
#' @return named vector of records, if no results found NULL
#' @export
#' @example examples/gb_record_get.R
#' @seealso [ncbi_acc_get()]
gb_record_get <- function(id) {
  res <- gb_sql_query(nm = 'raw_record,raw_sequence', id = id)
  rcs <- res[['raw_record']]
  seqs <- res[['raw_sequence']]
  with_seq <- which(vapply(X = seqs, FUN = function(x) x != '', logical(1)))
  # stick inf and seq together to make complete record
  # inverse of '\nORIGIN\\s+\n\\s+1\\s+'
  rcs[with_seq] <- lapply(X = with_seq, FUN = function(x) {
    paste0(rcs[[x]], '\nORIGIN      \n        1 ', seqs[[x]])
  })
  names(rcs) <- res[['accession']]
  unlist(rcs)
}

#' @name gb_definition_get
#' @title Get definition from GenBank
#' @family get
#' @description Return the definition line
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of definitions, if no results found NULL
#' @export
#' @example examples/gb_definition_get.R
#' @seealso [ncbi_acc_get()]
gb_definition_get <- function(id) {
  res <- gb_sql_query(nm = 'raw_definition', id = id)
  dfs <- res[['raw_definition']]
  names(dfs) <- res[['accession']]
  unlist(dfs)
}

#' @name gb_organism_get
#' @title Get organism from GenBank
#' @family get
#' @description Return the organism name
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of definitions, if no results found NULL
#' @export
#' @example examples/gb_organism_get.R
#' @seealso [ncbi_acc_get()]
gb_organism_get <- function(id) {
  res <- gb_sql_query(nm = 'organism', id = id)
  if (nrow(res) == 0) {
    return(NULL)
  }
  ors <- res[['organism']]
  names(ors) <- res[['accession']]
  ors
}

#' @name gb_version_get
#' @title Get version from GenBank
#' @family get
#' @description Return the accession version
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return named vector of versions, if no results found NULL
#' @export
#' @example examples/gb_version_get.R
#' @seealso [ncbi_acc_get()]
gb_version_get <- function(id) {
  res <- gb_sql_query(nm = 'version', id = id)
  vrs <- paste0(res[['accession']], '.', res[['version']])
  names(vrs) <- res[['accession']]
  vrs
}
