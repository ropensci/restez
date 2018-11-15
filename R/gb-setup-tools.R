#' @name flatfile_read
#' @title Read flatfile sequence records
#' @description Read records from a .seq file.
#' @param flpth Path to .seq file
#' @return list of GenBank records in text format
#' @family private
flatfile_read <- function(flpth) {
  generate_records <- function(i) {
    indexes <- record_starts[i]:record_ends[i]
    record <- paste0(lines[indexes], collapse = '\n')
    record
  }
  connection <- file(flpth, open = "r")
  lines <- readLines(con = connection)
  close(connection)
  if (length(lines) < 100) {
    return(list())
  }
  # throwaway file header
  first_record_start <- which(grepl(pattern = '^LOCUS', x = lines[1:100]))[1]
  lines <- lines[first_record_start:length(lines)]
  # read files
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
#' All sequences have to be at least as long as min and less than or equal
#' in length to max, unless max is NULL in which there is no maximum length.
#' @param records character, vector of GenBank records in text format
#' @param min_length Minimum sequence length, default 0.
#' @param max_length Maximum sequence length, default NULL.
#' @return data.frame
#' @family private
gb_df_generate <- function(records, min_length=0, max_length=NULL) {
  infoparts <- unname(vapply(X = records, FUN = extract_inforecpart,
                             FUN.VALUE = character(1)))
  # not all records have sequences, in which the whole record is the infopart
  pull <- infoparts == ''
  infoparts[pull] <- records[pull]
  seqrecparts <- unname(vapply(X = records, FUN.VALUE = character(1),
                               FUN = extract_seqrecpart))
  accessions <- unname(vapply(X = infoparts, FUN.VALUE = character(1),
                              FUN = extract_accession))
  versions <- unname(vapply(X = infoparts, FUN.VALUE = character(1),
                            FUN = extract_version))
  versions <- as.integer(sub(pattern = '^.*\\.', replacement = '',
                             x = versions))
  definitions <- unname(vapply(X = infoparts, FUN.VALUE = character(1),
                               FUN = extract_definition))
  organisms <- unname(vapply(X = infoparts, FUN.VALUE = character(1),
                             FUN = extract_organism))
  # filter by sequence lengths
  seqlengths <- unname(vapply(X = seqrecparts, FUN = function(x) {
    nchar(extract_clean_sequence(x))
    }, FUN.VALUE = integer(1)))
  pull <- seqlengths >= min_length
  if (!is.null(max_length)) {
    pull <- pull & seqlengths <= max_length
  }
  gb_df_create(accessions = accessions[pull], versions = versions[pull],
               organisms = organisms[pull], definitions = definitions[pull],
               sequences = seqrecparts[pull], records = infoparts[pull])
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
#' @description Add records data.frame to SQL-like database.
#' @param df Records data.frame
#' @return NULL
#' @family private
gb_sql_add <- function(df) {
  connection <- connection_get()
  if (!restez_ready()) {
    DBI::dbBegin(conn = connection)
    # https://www.ncbi.nlm.nih.gov/Sequin/acc.html
    # why does TINYINT not work?
    DBI::dbSendQuery(conn = connection, "CREATE TABLE nucleotide (
            accession VARCHAR(20),
            version INT,
            organism VARCHAR(100),
            raw_definition BLOB,
            raw_sequence BLOB,
            raw_record BLOB,
            PRIMARY KEY (accession)
            )")
    DBI::dbCommit(conn = connection)
  }
  DBI::dbWriteTable(conn = connection, name = 'nucleotide', value = df,
                    append = TRUE)
}

#' @name gb_build
#' @title Read and add .seq files to database
#' @description Given a list of seq_files, read and add the contents of the
#' files to a SQL-like database. If any errors during the process, FALSE is
#' returned.
#' @details This function will automatically connect to the restez database.
#' @param dpth Download path (where seq_files are stored)
#' @param seq_files .seq.tar seq file names
#' @param max_length Maximum sequence length
#' @param min_length Minimum sequence length
#' @return Logical
#' @family private
gb_build <- function(dpth, seq_files, max_length, min_length) {
  quiet_connect()
  on.exit(restez_disconnect())
  read_errors <- FALSE
  for (i in seq_along(seq_files)) {
    seq_file <- seq_files[[i]]
    stat_i <- paste0(i, '/', length(seq_files))
    cat_line('... ', char(seq_file), ' (', stat(stat_i), ')')
    flpth <- file.path(dpth, seq_file)
    records <- flatfile_read(flpth = flpth)
    if (length(records) > 0) {
      df <- gb_df_generate(records = records, min_length = min_length,
                           max_length = max_length)
      gb_sql_add(df = df)
      add_rcrd_log(fl = seq_file)
    } else {
      read_errors <- TRUE
      cat_line('... ... Hmmmm... no records found in that file.')
    }
  }
  read_errors
}
