filepath <- file.path('other', "gbpri10.seq")
records <- restez:::flatfile_read(filepath)
records <- sample(records, 25)
save(records, file = file.path('data', 'records.rda'), compress = 'xz')
