# Accessions records that have caused problems
# AI570151  -- origin in description
# AI607683  -- accession in description
# EP216306 -- contig, synthetic sequences, multiple accessions
# AACY020000000 -- wgs
# KBQR00000000 -- targeted locus study
# AB467315 -- feature location information over more than one line

# Background ----
#' @name extract_by_patterns
#' @title Extract by keyword
#' @description Search through GenBank record for a keyword and
#' return text up to the end_pattern.
#' @param record GenBank record in text format, character
#' @param start_pattern REGEX pattern indicating the point to
#' start extraction, character
#' @param end_pattern REGEX pattern indicating the point to
#' stop extraction, character
#' @details The start_pattern should be any of the capitalized elements
#' in a GenBank record (e.g. LOCUS, DESCRIPTION, ACCESSION).
#' The end_pattern depends on how much of the selected element
#' a user wants returned. By default, the extraction will stop
#' at the next newline.
#' If keyword or end pattern not found, returns NULL.
#' @return character or NULL
#' @family private
extract_by_patterns <- function(record, start_pattern, end_pattern='\n') {
  # have to make sure the text is formatted in a readable-format
  record <- iconv(x = record, from = 'latin1', to = 'latin1', sub = '-')
  # cut record from keyword to end_pattern
  start_index <- regexpr(pattern = start_pattern, text = record)
  if (start_index == -1) {
    return(NULL)
  }
  start_at <- start_index + attr(start_index, 'match.length')
  part_record <- substr(x = record, stop = nchar(record), start = start_at)
  end_index <- regexpr(pattern = end_pattern, text = part_record)
  if (end_index == -1) {
    return(NULL)
  }
  res  <- substr(x = part_record, start = 1, stop = end_index - 1)
  res <- sub(pattern = paste0(start_pattern, '\\s+'), replacement = '',
             x = res)
  res
}

#' @name extract_inforecpart
#' @title Extract the information record part
#' @description Return information part from GenBank record
#' @param record GenBank record in text format, character
#' @details If element is not found, '' returned.
#' @return character
#' @family private
extract_inforecpart <- function(record) {
  # stop at either beginning of sequence or if no seq, the TLS
  inforecpart <- extract_by_patterns(record = record, start_pattern = '^',
                                     end_pattern = '\nORIGIN\\s+\n\\s+1\\s+')
  if (is.null(inforecpart)) {
    inforecpart <- ''
  }
  inforecpart
}

#' @name extract_seqrecpart
#' @title Extract the sequence record part
#' @description Return sequence part from GenBank record
#' @param record GenBank record in text format, character
#' @details If element is not found, '' returned.
#' @return character
#' @family private
extract_seqrecpart <- function(record) {
  seqrecpart <- extract_by_patterns(record = record, end_pattern = '$',
                                    start_pattern = '\nORIGIN\\s+\n\\s+1\\s+')
  if (is.null(seqrecpart)) {
    seqrecpart <- ''
  }
  seqrecpart
}

#' @name extract_clean_sequence
#' @title Extract clean sequence from sequence part
#' @description Return clean sequence from seqrecpart of a GenBank record
#' @param seqrecpart Sequence part of a GenBank record, character
#' @param max_len Number: maximum number of characters allowed in a single
#' record before splitting the record into parts. Does not affect output,
#' but only internal calculations, so generally should not be changed.
#' Default = 1e8.
#' @details If element is not found, '' returned.
#' @return character
#' @family private
extract_clean_sequence <- function(seqrecpart, max_len = 1e8) {
  # If number of chars in sequence part is too long for gsub(),
  # split into chunks each no bigger than max_len chars
  if (nchar(seqrecpart) > max_len) {
    seqrecpart <- stringi::stri_sub(
      seqrecpart,
      seq(1, stringi::stri_length(seqrecpart),
          by = max_len),
      length = max_len
    )
  }
  # Extract the DNA sequence from each part
  seq <- paste0(
    sapply(
      seqrecpart,
      function(x) gsub(pattern = '([0-9]|\\s+|\n|/)', replacement = '', x)
    ),
    collapse = ""
  )
  # upper case is recommended, at least it is what rentrez returns
  toupper(seq)
}

# Foreground ----

#' @name extract_version
#' @title Extract version
#' @description Return accession + version ID from GenBank record
#' @details If element is not found, '' returned.
#' @param record GenBank record in text format, character
#' @return character
#' @family private
extract_version <- function(record) {
  vrsn <- extract_by_patterns(record = record,
                              start_pattern = '\nVERSION\\s{2,}')
  if (is.null(vrsn)) {
    return('')
  }
  vrsn
}

#' @name extract_accession
#' @title Extract accession
#' @description Return accession ID from GenBank record
#' @details If element is not found, '' returned.
#' @param record GenBank record in text format, character
#' @return character
#' @family private
extract_accession <- function(record) {
  accssn <- extract_by_patterns(record = record,
                                start_pattern = '\nACCESSION\\s{2,}')
  if (is.null(accssn)) {
    return('')
  }
  if (grepl(pattern = '\\s', x = accssn)) {
    accssn <- sub(pattern = '\\s.*', replacement = '', x = accssn)
  }
  accssn
}

#' @name extract_organism
#' @title Extract organism
#' @description Return organism name from GenBank record
#' @details If element is not found, '' returned.
#' @param record GenBank record in text format, character
#' @return character
#' @family private
extract_organism <- function(record) {
  orgnsm <- extract_by_patterns(record = record,
                                start_pattern = '\n\\s{1,}ORGANISM\\s{1,}')
  if (is.null(orgnsm)) {
    return('')
  }
  orgnsm
}

#' @name extract_definition
#' @title Extract definition
#' @description Return definition from GenBank record.
#' @details If element is not found, '' returned.
#' @param record GenBank record in text format, character
#' @return character
#' @family private
extract_definition <- function(record) {
  # assumes ACCESSION always follows DEFINTION
  definition <- extract_by_patterns(record = record,
                                    start_pattern = '\nDEFINITION\\s{2,}',
                                    end_pattern = '\nACCESSION\\s{2,}')
  if (is.null(definition)) {
    return('')
  }
  # clean
  definition <- gsub(pattern = '\n', replacement = '', x = definition)
  definition <- gsub(pattern = '\\s{2,}', replacement = ' ', x = definition)
  definition <- sub(pattern = '\\.$', replacement = '', x = definition)
  definition
}

#' @name extract_sequence
#' @title Extract sequence
#' @description Return sequence from GenBank record
#' @param record GenBank record in text format, character
#' @details If element is not found, '' returned.
#' @return character
#' @family private
extract_sequence <- function(record) {
  extract_clean_sequence(extract_seqrecpart(record))
}

#' @name extract_locus
#' @title Extract locus
#' @description Return locus information from GenBank record
#' @param record GenBank record in text format, character
#' @return named character vector
#' @details If element is not found, '' returned.
#' @family private
extract_locus <- function(record) {
  locus <- extract_by_patterns(record = record,
                               start_pattern = 'LOCUS\\s{2,}',
                               end_pattern = '\nDEFINITION\\s{2,}')
  if (is.null(locus)) {
    return('')
  }
  locus_elements <- strsplit(x = locus, split = '\\s+')[[1]]
  locus_elements <- locus_elements[!grepl(pattern = '^bp$',
                                          x = locus_elements)]
  names(locus_elements) <- c('accession', 'length', 'mol', 'type', 'domain',
                             'date')
  locus_elements
}

#' @name extract_features
#' @title Extract features
#' @description Return feature table as list from GenBank record
#' @param record GenBank record in text format, character
#' @return list of lists
#' @details If element is not found, empty list returned.
#' @family private
extract_features <- function(record) {
  feature_text <- extract_by_patterns(record = record,
                                      start_pattern = '\nFEATURES\\s{3,}',
                                      end_pattern = '\n[A-Z]{2,}\\s+')
  if (is.null(feature_text)) {
    return(list())
  }
  features_lines <- strsplit(x = feature_text, split = '\n')[[1]][-1]
  features <- list()
  i <- 0
  nm <- ''
  # identify location information
  common_pttrn <- '\\s(complement\\()?[0-9]+(\\.\\.[0-9]+)?\\)?$'
  join_pttrn <- '\\sjoin\\([0-9]+\\.\\.[0-9]+,'
  for (ln in features_lines) {
    with_location <- grepl(pattern = common_pttrn, x = ln) |
      grepl(pattern = join_pttrn, x = ln)
    if (with_location) {
      # if location information create a new features element
      typ_location <- strsplit(x = ln, split = '\\s+')[[1]][-1]
      if (length(typ_location) > 1) {
        i <- i + 1
        features[[i]] <- list()
        features[[i]][['type']] <- typ_location[[1]]
        features[[i]][['location']] <- typ_location[[2]]
      } else {
        features[[i]][['location']] <- paste0(features[[i]][['location']],
                                              typ_location[[1]])
      }
    } else {
      nm_value <- strsplit(x = ln, split = '=')[[1]]
      if (length(nm_value) < 2) {
        # if not two spaced items, assume it is part of the last element
        # e.g. AC087884
        value <- trimws(x = nm_value)
        value <- gsub(pattern = '\"', replacement = '', x = value)
        features[[i]][[nm]] <- paste0(features[[i]][[nm]], value)
      } else {
        nm <- trimws(x = nm_value[[1]])
        nm <- sub(pattern = '/', replacement = '', x = nm)
        value <- trimws(x = nm_value[[2]])
        value <- gsub(pattern = '\"', replacement = '', x = value)
        features[[i]][[nm]] <- value
      }
    }
  }
  features
}

#' @name extract_keywords
#' @title Extract keywords
#' @description Return keywords as list from GenBank record
#' @param record GenBank record in text format, character
#' @return character vector
#' @details If element is not found, '' returned.
#' @family private
extract_keywords <- function(record) {
  keyword_text <- extract_by_patterns(record = record,
                                      start_pattern = 'KEYWORDS\\s{2,}',
                                      end_pattern = 'SOURCE\\s{2,}')
  if (is.null(keyword_text)) {
    return('')
  }
  # remove .
  keyword_text <- sub(pattern = '\\.\n$', replacement = '', x = keyword_text)
  # split up
  keyword_text <- strsplit(x = keyword_text, split = ';\\s+')[[1]]
  # patch: prevent return of "character(0)"
  if (length(keyword_text) == 0) {
    keyword_text <- ''
  }
  keyword_text
}

# Public ----

#' @name gb_extract
#' @title Extract elements of a GenBank record
#' @description Return elements of GenBank record e.g. sequence, definition ...
#' @details This function uses a REGEX to extract particular elements of a
#' GenBank record. All of the what options return a single character with the
#' exception of 'locus' or 'keywords' that return character vectors and
#' 'features' that returns a list of lists for all features.
#'
#'
#' The accuracy of these functions cannot be guaranteed due to the enormity of
#' the GenBank database. But the function is regularly tested on a range of
#' GenBank records.
#'
#' Note: all non-latin1 characters are converted to '-'.
#' @param record GenBank record in text format, character
#' @param what Which element to extract
#' @example examples/gb_extract.R
#' @return character or list of lists (what='features') or named character
#' vector (what='locus')
#' @family parse
#' @export
gb_extract <- function(record, what=c('accession', 'version', 'organism',
                                      'sequence', 'definition', 'locus',
                                      'features', 'keywords')) {
  what <- match.arg(arg = what)
  switch(what, accession = extract_accession(record = record),
         version = extract_version(record = record),
         organism = extract_organism(record = record),
         sequence = extract_sequence(record = record),
         definition = extract_definition(record = record),
         locus = extract_locus(record = record),
         keywords = extract_keywords(record = record),
         features = extract_features(record = record))
}
