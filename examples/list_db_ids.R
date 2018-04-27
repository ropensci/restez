library(restez)
restez_path_set(filepath = tempdir())
demo_db_create(n = 10)
# Warning: not recommended for real databases
#  with potentially millions of IDs
all_ids <- list_db_ids()


# What shall we do with these IDs?
# ... how about make a mock fasta file
seqs <- gb_sequence_get(id = all_ids)
defs <- gb_definition_get(id = all_ids)
# paste together
fasta_seqs <- paste0('>', defs, '\n', seqs)
fasta_file <- paste0(fasta_seqs, collapse = '\n')
cat(fasta_file)


# delete after example
db_delete()
