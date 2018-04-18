#' @name mock_rec
#' @title Mock rec
#' @description Create a mock GenBank record for demo-ing and
#' testing purposes. Designed to be part of a loop.
#' Accession, organism... etc. are optional arguments.
#' @param i integer, iterator
#' @param accession character
#' @param organism character
#' @param definition character
#' @param sequence character
#' @return character
#' @noRd
mock_rec <- function(i, definition=NULL, accession=NULL,
                     organism=NULL, sequence=NULL) {
  paste0('LOCUS       [This is a mock GenBank data record]\n',
         'DEFINITION  ', definition, '\n',
         'ACCESSION   ', accession, '\n',
         'VERSION     [version]\n',
         'KEYWORDS    [keyword]\n',
         'SOURCE      [tissue, organism]\n',
         'ORGANISM    ', organism, '\n',
         'REFERENCE   [reference data]\n',
         'AUTHORS     [all the authors]\n',
         'TITLE       [title]\n',
         'JOURNAL     [journal]\n',
         'FEATURES    [features]\n',
         'ORIGIN\n        1 ', sequence, '\n//')
}

#' @name mock_seq
#' @title Mock seq
#' @description Make a mock sequence. Designed to be part of a loop.
#' @param i integer, iterator
#' @param sqlngth integer, sequence length
#' @return character
#' @noRd
mock_seq <- function(i, sqlngth = 10) {
  paste0(sample(x = c('a', 't', 'c', 'g'), size = sqlngth,
                replace = TRUE), collapse = '')
}

#' @name mock_def
#' @title Mock def
#' @description Make a mock sequence definition.
#' Designed to be part of a loop.
#' @param i integer, iterator
#' @return character
#' @noRd
mock_def <- function(i) {
  paste0('A demonstration sequence | id demo_', i)
}

#' @name mock_org
#' @title Mock org
#' @description Make a mock sequence organism.
#' Designed to be part of a loop.
#' @param i integer, iterator
#' @return character
#' @noRd
mock_org <- function(i) {
  paste0('Unreal organism ', i)
}

#' @name mock_nucleotide_df
#' @title Mock nucleotide df
#' @description Make a mock nucleotide data.frame
#' for entry into a demonstration SQL database.
#' @param n integer, number of entries
#' @return data.frame
#' @noRd
mock_nucleotide_df <- function(n) {
  accession <- paste0('demo_', 1:n)
  sequence <- vapply(X = 1:n, FUN = mock_seq, FUN.VALUE = character(1))
  definition <- vapply(X = 1:n, FUN = mock_def, FUN.VALUE = character(1))
  organism <- vapply(X = 1:n, FUN = mock_org, FUN.VALUE = character(1))
  record <- vapply(X = 1:n, FUN = function(i) {
    mock_rec(i, definition = definition[[i]],
             accession = accession[[i]],
             organism = organism[[i]],
             sequence = sequence[[i]])
  }, FUN.VALUE = character(1))
  make_nucleotide_df(accessions = accession,
                     organisms = organism,
                     definitions = definition,
                     sequences = sequence,
                     records = record)
}