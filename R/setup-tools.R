#' @name setup_database
#' @title Setup database
#' @description Download and create GenBank database
#' @return NULL
#' @export
setup_database <- function() {

}

#' @name read_records
#' @title Read records
#' @description Read records from a .seq file.
#' @param filepath Path to .seq file
#' @return list of GenBank records in text format
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
#' @param records list of GenBank records in text format
#' @return data.frame
generate_dataframe <- function(records) {
  accessions <- vapply(X = records, FUN.VALUE = character(1),
                       FUN = get_version)
  definitions <- vapply(X = records, FUN.VALUE = character(1),
                        FUN = get_definition)
  organisms <- vapply(X = records, FUN.VALUE = character(1),
                      FUN = get_organism)
  sequences <- vapply(X = records, FUN.VALUE = character(1),
                      FUN = get_sequence)
  # make raw
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
