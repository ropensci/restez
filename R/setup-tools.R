#' @name read_records
#' @title Read records
#' @description Read records from a .seq file.
#' @param filepath Path to .seq file
#' @return list of GenBank records in text format
#' @noRd
read_records <- function(filepath) {
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
  records <- lapply(X = seq_along(record_ends),
                    FUN = generate_records)
  records
}

#' @name generate_dataframe
#' @title Generate records data.frame
#' @description For a list of records, construct a data.frame
#' for insertion into SQL database.
#' @details The resulting data.frame has five columns: accession,
#' organism, raw_definition, raw_sequence, raw_record.
#' The prefix 'raw_' indicates the data has been covnerted to the
#' raw format, see ?charToRaw, in order to save on RAM.
#' The raw_record contains the entire GenBank record in text format.
#' @param records character, vector of GenBank records in text format
#' @return data.frame
#' @noRd
# TODO: name will need updating if any new databases other than GB
# are incorportated
generate_dataframe <- function(records) {
  accessions <- vapply(X = records, FUN.VALUE = character(1),
                       FUN = extract_accession)
  definitions <- vapply(X = records, FUN.VALUE = character(1),
                        FUN = extract_definition)
  organisms <- vapply(X = records, FUN.VALUE = character(1),
                      FUN = extract_organism)
  sequences <- vapply(X = records, FUN.VALUE = character(1),
                      FUN = extract_sequence)
  make_nucleotide_df(accessions = accessions,
                     organisms = organisms,
                     definitions = definitions,
                     sequences = sequences,
                     records = records)
}

#' @name make_nucleotide_df
#' @title Make nucleotide df
#' @description Make data.frame from columns vectors for
#' nucleotide entries. As part of generate_dataframe().
#' @param accessions character, vector of accession versions
#' @param organisms character, vector of organism names
#' @param definitions character, vector of sequence definitions
#' @param sequences character, vector of sequences
#' @param records character, vector of GenBank records in text format
#' @return data.frame
#' @noRd
make_nucleotide_df <- function(accessions, organisms, definitions,
                               sequences, records) {
  raw_definitions <- lapply(definitions, charToRaw)
  raw_sequences <- lapply(sequences, charToRaw)
  raw_records <- lapply(records, charToRaw)
  df <- data.frame(accession = accessions,
                   organism = organisms,
                   raw_definition = I(raw_definitions),
                   raw_sequence = I(raw_sequences),
                   raw_record = I(raw_records))
  df
}

#' @name add_to_database
#' @title Add to database
#' @description Add records data.frame to SQLite database.
#' @param df Records data.frame
#' @param database Database name
#' @return NULL
#' @noRd
add_to_database <- function(df, database) {
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = get_sql_path())
  on.exit(DBI::dbDisconnect(conn = connection))
  DBI::dbWriteTable(conn = connection, name = database,
                    value = df, append = TRUE)
}
