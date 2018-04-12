filepath <- file.path('other', "gbpri10.seq")
records <- restez:::read_records(filepath)
records <- sample(records, 25)
save(records, file = file.path('data', 'records.rda'), compress = 'xz')
