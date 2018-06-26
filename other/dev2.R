library(restez)

record <- rentrez::entrez_fetch(db = 'nucleotide', id = 'AY952423', rettype = 'gb', retmode = 'text')
gb_extract(record = record, what = 'features')
save(record, file = 'data/record.rda', compress = 'xz')
