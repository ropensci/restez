library(restez)
set_restez_path(tempdir())
create_demo_database()
# return fasta record
fasta_res <- entrez_fetch(db = 'nucleotide',
                          id = c('demo_1', 'demo_2'),
                          rettype = 'fasta')
cat(fasta_res)
# return whold GB record in text format
gb_res <- entrez_fetch(db = 'nucleotide',
                       id = c('demo_1', 'demo_2'),
                       rettype = 'gb')
cat(gb_res)
# NOT RUN
# whereas these request would go through rentrez
# fasta_res <- entrez_fetch(db = 'nucleotide',
#                           id = c('S71333', 'S71334'),
#                           rettype = 'fasta')
# gb_res <- entrez_fetch(db = 'nucleotide',
#                        id = c('S71333', 'S71334'),
#                        rettype = 'gb')

# delete demo after example
delete_database()
