# LIBS
library(restez)

# SETUP
fp <- file.path(getwd(), 'demo')
dir.create(fp)
restez_path_set(fp)
gb_download()
db_create()

# LOOK UP ACCESSIONS
# 33553 - Sciuromorpha - squirrel-like things
search_term <- 'txid33553[Organism:exp] AND COI [GENE]'
search_object <- rentrez::entrez_search(db = 'nucleotide', term = search_term,
                                        use_history = TRUE, retmax = 0)
accessions <- rentrez::entrez_fetch(db = 'nucleotide',
                                    web_history = search_object$web_history,
                                    rettype = 'acc')
accessions <- strsplit(x = accessions, split = '\\n')[[1]]
accessions <- sub(pattern = '\\.[0-9]+', replacement = '', x = accessions)

# FETCH
coi_sequences <- gb_fasta_get(id = accessions)
# are all accessions in results?
all(accessions %in% names(coi_sequences))
# .... no
accessions[!accessions %in% names(coi_sequences)]
# NC* refers to RefSeq sequences and are not currently available through restez
# The sequence however exists in GB under a different id which we can find like so
smmry <- rentrez::entrez_summary(db = 'nucleotide', id = 'NC_027278')
# This ID does exist in our results.
smmry$assemblyacc %in% accessions

# TAKE DOWN
db_delete()
