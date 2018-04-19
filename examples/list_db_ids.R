library(restez)
set_restez_path(filepath = tempdir())
create_demo_database(n = 10)
# Warning: not recommended for real databases
#  with potentially millions of IDs
all_ids <- list_db_ids()
# What shall we do with these IDs?
# ... how about make a mock fasta file
seqs <- get_sequence(id = all_ids)
defs <- get_definition(id = all_ids)
# paste together
fasta_seqs <- paste0('>', defs, '\n', seqs)
fasta_file <- paste0(fasta_seqs, collapse = '\n')
cat(fasta_file)

# delete after example
delete_database()
