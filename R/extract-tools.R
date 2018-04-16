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
#' @description Return version ID from GenBank record
#' @param record GenBank record in text format, character
#' @return character
#' @noRd
extract_version <- function(record) {
  extract_by_keyword(record = record, keyword = 'VERSION')
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
