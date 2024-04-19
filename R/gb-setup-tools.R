#' @name flatfile_read
#' @title Read flatfile sequence records
#' @description Read records from a .seq file.
#' @param flpth Path to .seq file
#' @return list of GenBank records in text format
#' @family private
flatfile_read <- function(flpth) {
  generate_records <- function(i) {
    indexes <- record_starts[i]:record_ends[i]
    record <- try(paste0(lines[indexes], collapse = '\n'))
    if (inherits(record, "try-error")){
      warning("Record too long, dropping. Here is the first line:")
      print(lines[1])
      record = NULL
    }
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
  # return character vector
  unlist(records)
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
#' Use `acc_filter` and max and min sequence lengths to minimize the size of the
#' database. All sequences have to be at least as long as min and less than or
#' equal in length to max, unless max is NULL in which there is no maximum
#' length. The final selection of sequences is the result of applying all
#' filters (`acc_filter`, `min_length`, `max_length`) in combination.
#'
#' @param records character, vector of GenBank records in text format
#' @param min_length Minimum sequence length, default 0.
#' @param max_length Maximum sequence length, default NULL.
#' @param acc_filter Character vector; accessions to include or exclude from
#' the database as specified by `invert`.
#' @param invert Logical vector of length 1; if TRUE, accessions in `acc_filter`
#' will be excluded from the database; if FALSE, only accessions in `acc_filter`
#' will be included in the database. Default FALSE.
#' @return data.frame, or NULL if no records pass filters
#' @family private
gb_df_generate <- function(records, min_length=0, max_length=NULL,
  acc_filter = NULL, invert = FALSE) {
  # Convert records to character vector if needed
  if (inherits(records, "list")) {
    records <- unlist(records)
  }
  if (!is.character(records)) stop("'records' must be a character vector")
  # Extract info part of record (part other than sequence)
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
  # reset `pull` before filtering
  pull <- rep(TRUE, length(seqrecparts))
  # filter by sequence lengths
  # only calculate seq length if needed
  if (!is.null(max_length) | min_length > 0) {
    seqlengths <- unname(vapply(X = seqrecparts, FUN = function(x) {
      nchar(extract_clean_sequence(x))
      }, FUN.VALUE = integer(1)))
  }
  if (min_length > 0) {
    pull <- seqlengths >= min_length
  }
  if (!is.null(max_length)) {
    pull <- pull & seqlengths <= max_length
  }
  # filter by accessions to include
  if (!is.null(acc_filter)) {
    if (invert) {
      pull <- pull & !(accessions %in% acc_filter)
    } else {
      pull <- pull & accessions %in% acc_filter
    }
  }
  if (!any(pull)) {
    return(NULL)
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
  df <- data.frame(accession = accessions, version = versions,
                   organism = organisms, raw_definition = definitions,
                   raw_sequence = sequences, raw_record = records)
  df
}

#' @name gb_sql_add
#' @title Add to GenBank SQL database
#' @description Add records data.frame to SQL-like database.
#' @param df Records data.frame
#' @return NULL
#' @family private
gb_sql_add <- function(df) {
  is_restez_ready <- restez_ready()
  restez_connect()
  connection <- connection_get()
  if (!is_restez_ready) {
    # https://www.ncbi.nlm.nih.gov/Sequin/acc.html
    # why does TINYINT not work?
    DBI::dbExecute(conn = connection, "CREATE TABLE nucleotide (
            accession VARCHAR(20),
            version INT,
            organism VARCHAR(100),
            raw_definition VARCHAR,
            raw_sequence VARCHAR,
            raw_record VARCHAR,
            PRIMARY KEY (accession)
            )")
  }
  DBI::dbWriteTable(conn = connection, name = 'nucleotide', value = df,
                    append = TRUE)
  restez_disconnect()
}

#' @name gb_build
#' @title Read and add .seq files to database
#' @description Given a list of seq_files, read and add the contents of the
#' files to a SQL-like database. If any errors during the process, FALSE is
#' returned.
#' @details This function will automatically connect to the restez database.
#'
#' @inheritParams gb_df_generate
#' @param dpth Download path (where seq_files are stored)
#' @param seq_files .seq.tar seq file names
#' @param scan Logical vector of length 1; should the sequence file be scanned
#' for accessions in `acc_filter` prior to processing?
#' Requires zgrep to be installed (so does not work on Windows).
#' Only used if `acc_filter` is not NULL and `invert` is FALSE. Default FALSE.
#' @return Logical
#' @family private
gb_build <- function(
  dpth, seq_files, max_length, min_length,
  acc_filter = NULL, invert = FALSE, scan = FALSE) {
  on.exit(restez_disconnect())
  read_errors <- FALSE
  for (i in seq_along(seq_files)) {
    seq_file <- seq_files[[i]]
    stat_i <- paste0(i, '/', length(seq_files))
    cat_line('... ', char(seq_file), ' (', stat(stat_i), ')')
    flpth <- file.path(dpth, seq_file)
    # File scanning: faster method to skip loading record if
    # no desired accessions are present
    if (isTRUE(scan) && !is.null(acc_filter) && invert == FALSE) {
      records_detected <- search_gz(acc_filter, flpth)
      if (!records_detected) {
        cat_line('... ... No accessions in acc_filter detected; skipping file.')
        next
      }
    }
    records <- flatfile_read(flpth = flpth)
    if (length(records) > 0) {
      df <- gb_df_generate(records = records, min_length = min_length,
                           max_length = max_length, acc_filter = acc_filter,
                           invert = invert)
      if (!is.null(df)) {
        gb_sql_add(df = df)
        add_rcrd_log(fl = seq_file)
      } else {
        cat_line('... ... No sequences found that meet filters; skipping file.')
        next
      }
    } else {
      read_errors <- TRUE
      cat_line('... ... Hmmmm... no records found in that file.')
    }
  }
  read_errors
}

#' @name search_gz
#' @title Scan a gzipped file for text
#' @description Scans a zipped file for text
#' strings and returns TRUE if any are present.
#' @param terms Character vector; search terms (most likely GenBank accession
#' numbers)
#' @param path Path to the gzipped file to scan
#' @return Logical
#' @family private
search_gz <- function(terms, path) {
  # Skip scan if no zgrep
  if (nchar(Sys.which("zgrep")) == 0) {
    warning("Cannot scan gzipped file without zgrep; skipping scan")
    return(TRUE)
  }
  # There are a potentially large number of terms,
  # so grepping works best with external files
  temp_file <- tempfile()
  writeLines(terms, temp_file)
  # Run zgrep
  command <- paste(
    "zgrep -c -F -f",
    temp_file,
    path
  )
  # zgrep returns count of times any of the accessions occurred in the file
  search_res <- as.integer(
    suppressWarnings(system(command, intern = TRUE))
  )
  # Done with temp file
  unlink(temp_file)
  # Return TRUE if at least one accession found
  search_res > 0
}
