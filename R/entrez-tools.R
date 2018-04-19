# entrez tools should run rentrez if they do not return all request IDs
#' @name get_entrez_fasta
#' @title Get Entrez fasta
#' @description Return fasta format as expected from
#' an Entrez call.
#' @param id vector, unique ID(s) for record(s)
#' @return character string containing the file created
#' @noRd
get_entrez_fasta <- function(id) {
  fastas <- get_fasta(id = id)
  paste0(paste(fastas, collapse = '\n\n'), '\n\n')
}

#' @name get_entrez_fasta
#' @title Get Entrez fasta
#' @description Return gb and gbwithparts format as expected from
#' an Entrez call.
#' @param id vector, unique ID(s) for record(s)
#' @return character string containing the file created
#' @noRd
get_entrez_gb <- function(id) {
  recs <- get_record(id = id)
  paste0(paste(recs, collapse = '\n\n'), '\n\n')
}
