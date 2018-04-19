library(restez)
set_restez_path(filepath = tempdir())
create_demo_database()
fasta <- get_fasta(id = 'demo_1')
fastas <- get_fasta(id = c('demo_1', 'demo_2'))

# delete demo after example
delete_database()
