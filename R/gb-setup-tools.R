#' @name flatfile_read
#' @title Read flatfile sequence records
#' @description Read records from a .seq file.
#' @param filepath Path to .seq file
#' @return list of GenBank records in text format
#' @family private
flatfile_read <- function(filepath) {
  generate_records <- function(i) {
    indexes <- record_starts[i]:record_ends[i]
    record <- paste0(lines[indexes], collapse = '\n')
    record
  }
  connection <- file(filepath, open = "r")
  lines <- readLines(con = connection)
  close(connection)
  record_ends <- which(lines == '//')
  record_starts <- c(1, record_ends[-1*length(record_ends)] + 1)
  records <- lapply(X = seq_along(record_ends), FUN = generate_records)
  records
}

#' @name gb_df_generate
#' @title Generate GenBank records data.frame
#' @description For a list of records, construct a data.frame
#' for insertion into SQL database.
#' @details The resulting data.frame has five columns: accession,
#' organism, raw_definition, raw_sequence, raw_record.
#' The prefix 'raw_' indicates the data has been converted to the
#' raw format, see ?charToRaw, in order to save on RAM.
#' The raw_record contains the entire GenBank record in text format.
#'
#' Use max and min sequence lengths to minimise the size of the database.
#' @param records character, vector of GenBank records in text format
#' @param min_length Minimum sequence length, default 0.
#' @param max_length Maximum sequence length, default NULL.
#' @return data.frame
#' @family private
gb_df_generate <- function(records, min_length=0, max_length=NULL) {
  accessions <- vapply(X = records, FUN.VALUE = character(1),
                       FUN = extract_accession)
  versions <- vapply(X = records, FUN.VALUE = character(1),
                     FUN = extract_version)
  definitions <- vapply(X = records, FUN.VALUE = character(1),
                        FUN = extract_definition)
  organisms <- vapply(X = records, FUN.VALUE = character(1),
                      FUN = extract_organism)
  sequences <- vapply(X = records, FUN.VALUE = character(1),
                      FUN = extract_sequence)
  seqlengths <- vapply(X = sequences, FUN = nchar, FUN.VALUE = integer(1))
  pull <- seqlengths >= min_length
  if (!is.null(max_length)) {
    pull <- pull & seqlengths <= max_length
  }
  gb_df_create(accessions = accessions[pull], versions = versions[pull],
               organisms = organisms[pull], definitions = definitions[pull],
               sequences = sequences[pull], records = records[pull])
}

#' @name gb_df_create
#' @title Create GenBank data.frame
#' @description Make data.frame from columns vectors for
#' nucleotide entries. As part of gb_df_generate().
#' @param accessions character, vector of accessions
#' @param versions character, vector of accessions + versions
#' @param organisms character, vector of organism names
#' @param definitions character, vector of sequence definitions
#' @param sequences character, vector of sequences
#' @param records character, vector of GenBank records in text format
#' @return data.frame
#' @family private
gb_df_create <- function(accessions, versions, organisms, definitions,
                         sequences, records) {
  raw_definitions <- lapply(definitions, charToRaw)
  raw_sequences <- lapply(sequences, charToRaw)
  raw_records <- lapply(records, charToRaw)
  df <- data.frame(accession = accessions, version = versions,
                   organism = organisms, raw_definition = I(raw_definitions),
                   raw_sequence = I(raw_sequences), raw_record = I(raw_records))
  df
}

#' @name gb_sql_add
#' @title Add to GenBank SQL database
#' @description Add records data.frame to SQLite database.
#' @param df Records data.frame
#' @param database Database name
#' @return NULL
#' @family private
gb_sql_add <- function(df, database) {
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(), dbname = sql_path_get())
  on.exit(DBI::dbDisconnect(conn = connection))
  if (restez_ready()) {
    DBI::dbWriteTable(conn = connection, name = database, value = df,
                      append = TRUE)
  } else {
    field.types <- list('accession' = 'primary key', 'version' = 'varchar',
                        'organism' = 'varchar', 'raw_definition' = '',
                        'raw_sequence' = '', 'raw_record' = '')
    DBI::dbWriteTable(conn = connection, name = database, value = df,
                      field.types = field.types)
  }
}
