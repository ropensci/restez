library(restez)
# create database
records <- restez:::read_records(filepath = file.path('other', 'gbpri10.seq'))
df <- restez:::generate_dataframe(records = records)
restez:::add_to_database(df = df, database = 'nucleotide')


id <- c("AC091913.2", "AC091914.3", "AC091915.4", "AC091917.3")
