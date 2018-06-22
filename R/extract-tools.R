#' @name extract_by_keyword
#' @title Extract by keyword
#' @description Search through GenBank record for a keyword and
#' return text up to the end_pattern.
#' @param record GenBank record in text format, character
#' @param keyword Keyword, character
#' @param end_pattern REGEX pattern indicating the point to
#' stop extraction, character
#' @details The keyword should be any of the capitalized elements
#' in a GenBank record (e.g. LOCUS, DESCRIPTION, ACCESSION).
#' The end_pattern depends on how much of the selected element
#' a user wants returned. By default, the extraction will stop
#' at the next newline.
#' @return character
#' @noRd
extract_by_keyword <- function(record, keyword, end_pattern='\n') {
  # cut record from keyword to end_pattern
  start_index <- regexpr(pattern = keyword, text = record)
  part_record <- substr(x = record, start = start_index,
                        stop = nchar(record))
  end_index <- regexpr(pattern = end_pattern, text = part_record)
  res  <- substr(x = part_record, start = 1,
                 stop = end_index - 1)
  res <- sub(pattern = paste0(keyword, '\\s+'),
             replacement = '', x = res)
  res
}

#' @name extract_version
#' @title Extract version
#' @description Return accession + version ID from GenBank record
#' @param record GenBank record in text format, character
#' @return character
#' @noRd
extract_version <- function(record) {
  extract_by_keyword(record = record, keyword = 'VERSION')
}

#' @name extract_accession
#' @title Extract accession
#' @description Return accession ID from GenBank record
#' @param record GenBank record in text format, character
#' @return character
#' @noRd
extract_accession <- function(record) {
  extract_by_keyword(record = record, keyword = 'ACCESSION')
}

#' @name extract_organism
#' @title Extract organism
#' @description Return organism name from GenBank record
#' @param record GenBank record in text format, character
#' @return character
#' @noRd
extract_organism <- function(record) {
  extract_by_keyword(record = record, keyword = 'ORGANISM')
}

#' @name extract_definition
#' @title Extract definition
#' @description Return definition from GenBank record
#' @param record GenBank record in text format, character
#' @return character
#' @noRd
extract_definition <- function(record) {
  # assumes ACCESSION always follows DEFINTION
  definition <- extract_by_keyword(record = record, keyword = 'DEFINITION',
                                   end_pattern = 'ACCESSION')
  # clean
  definition <- gsub('\n', '', definition)
  definition <- gsub('\\s{2,}', ' ', definition)
  definition
}

#' @name extract_sequence
#' @title Extract sequence
#' @description Return sequecne from GenBank record
#' @param record GenBank record in text format, character
#' @return character
#' @noRd
extract_sequence <- function(record) {
  sequence <- extract_by_keyword(record = record, keyword = 'ORIGIN',
                                 end_pattern = '//')
  # clean
  sequence <- gsub('([0-9]|\\s+|\n)', '', sequence)
  sequence 
}

#' @name extract_locus
#' @title Extract locus
#' @description Return locus information from GenBank record
#' @param record GenBank record in text format, character
#' @return named character vector
#' @noRd
extract_locus <- function(record) {
  locus <- extract_by_keyword(record = record, keyword = 'LOCUS',
                              end_pattern = 'DEFINITION')
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
#' @noRd
extract_features <- function(record) {
  feature_text <- extract_by_keyword(record = record, keyword = 'FEATURES',
                                     end_pattern = 'ORIGIN')
  features_lines <- strsplit(x = feature_text, split = '\n')[[1]]
  features_lines <- features_lines[!grepl(pattern = 'Location/Qualifiers',
                                          x = features_lines)]
  features <- list()
  i <- 0
  for (ln in features_lines) {
    with_location <- grepl(pattern = '[0-9]+\\.\\.[0-9]+', x = ln)
    if (with_location) {
      i <- i + 1
      features[[i]] <- list()
      typ_location <- strsplit(x = ln, split = '\\s+')[[1]][-1]
      features[[i]][['type']] <- typ_location[[1]]
      features[[i]][['location']] <- typ_location[[2]]
    } else {
      nm_value <- strsplit(x = ln, split = '=')[[1]]
      nm <- trimws(x = nm_value[[1]])
      nm <- sub(pattern = '/', replacement = '', x = nm)
      value <- trimws(x = nm_value[[2]])
      value <- gsub(pattern = '\"', replacement = '', x = value)
      features[[i]][[nm]] <- value
    }
  }
  features
}

#' @name gb_extract
#' @title Extract elements of a GenBank record
#' @description Return elements of GenBank record e.g. sequence, definition ...
#' @details This function uses a REGEX to extract particular elements of a
#' GenBank record. All of the what options return a single character with the 
#' exception of 'locus' that returns a named character vector of the first line
#' in a GB record and 'features' which returns a list of lists for all features.
#' 
#' 
#' The accuracy of these functions cannot be guarranteed due to the enormity of
#' the GenBank database. But the function is regurlarly tested on a range of
#' GenBank records.
#' @param record GenBank record in text format, character
#' @param what Which element to extract
#' @example examples/gb_extract.R
#' @return character or list of lists (what='features') or named character
#' vector (what='locus')
#' @export
gb_extract <- function(record, what=c('accession', 'version', 'organism',
                                      'sequence', 'definition', 'locus',
                                      'features')) {
  what <- match.arg(arg = what)
  switch(what, accession = extract_accession(record = record),
         version = extract_version(record = record),
         organism = extract_organism(record = record),
         sequence = extract_sequence(record = record),
         definition = extract_definition(record = record),
         locus = extract_locus(record = record),
         features = extract_features(record = record))
}
