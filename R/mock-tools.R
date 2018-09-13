#' @name mock_rec
#' @title Mock rec
#' @description Create a mock GenBank record for demo-ing and testing purposes.
#' Designed to be part of a loop. Accession, organism... etc. are optional
#' arguments.
#' @param i integer, iterator
#' @param accession character
#' @param organism character
#' @param definition character
#' @param sequence character
#' @param version character
#' @return character
#' @family private
mock_rec <- function(i, definition=NULL, accession=NULL,
                     version=NULL, organism=NULL, sequence=NULL) {
  rec <- paste0('LOCUS       [This is a mock GenBank data record]\n',
                'DEFINITION  ', definition, '\n',
                'ACCESSION   ', accession, '\n',
                'VERSION     ', version, '\n',
                'KEYWORDS    [keyword]\n',
                'SOURCE      [tissue, organism]\n',
                'ORGANISM    ', organism, '\n',
                'REFERENCE   [reference data]\n',
                'AUTHORS     [all the authors]\n',
                'TITLE       [title]\n',
                'JOURNAL     [journal]\n',
                'FEATURES    [features]\n')
  if (!is.null(sequence)) {
    rec <- paste0(rec, 'ORIGIN\n        1 ', sequence, '\n//')
  }
  rec
}

#' @name mock_seq
#' @title Mock seq
#' @description Make a mock sequence. Designed to be part of a loop.
#' @param i integer, iterator
#' @param sqlngth integer, sequence length
#' @return character
#' @family private
mock_seq <- function(i, sqlngth = 10) {
  sq <- paste0(sample(x = c('a', 't', 'c', 'g'), size = sqlngth,
                      replace = TRUE), collapse = '')
  paste0(sq, '\n')
}

#' @name mock_def
#' @title Mock def
#' @description Make a mock sequence definition.
#' Designed to be part of a loop.
#' @param i integer, iterator
#' @return character
#' @family private
mock_def <- function(i) {
  paste0('A demonstration sequence | id demo_', i)
}

#' @name mock_org
#' @title Mock org
#' @description Make a mock sequence organism.
#' Designed to be part of a loop.
#' @param i integer, iterator
#' @return character
#' @family private
mock_org <- function(i) {
  paste0('Unreal organism ', i)
}

#' @name mock_gb_df_generate
#' @title Generate mock GenBank records data.frame
#' @description Make a mock nucleotide data.frame
#' for entry into a demonstration SQL database.
#' @param n integer, number of entries
#' @return data.frame
#' @family private
mock_gb_df_generate <- function(n) {
  accession <- paste0('demo_', 1:n)
  version <- sample(x = 1L:4L, size = length(accession), replace = TRUE)
  sequence <- vapply(X = 1:n, FUN = mock_seq, FUN.VALUE = character(1))
  definition <- vapply(X = 1:n, FUN = mock_def, FUN.VALUE = character(1))
  organism <- vapply(X = 1:n, FUN = mock_org, FUN.VALUE = character(1))
  record <- vapply(X = 1:n, FUN = function(i) {
    mock_rec(i, definition = definition[[i]],
             accession = accession[[i]],
             version = version[[i]],
             organism = organism[[i]])
  }, FUN.VALUE = character(1))
  gb_df_create(accessions = accession, versions = version,
               organisms = organism, definitions = definition,
               sequences = sequence, records = record)
}
