library(restez)
data('records')

df <- restez:::generate_dataframe(records[1:10])
df <- restez:::generate_dataframe(records[11:20])
library(DBI)
con <- dbConnect(RSQLite::SQLite(), "database")
dbListTables(con)

dbWriteTable(con, "df", df, append=TRUE)
dbReadTable(con, 'df')
res <- dbSendQuery(con, "SELECT * FROM df WHERE accession = 'AC090857.8'")
data_row <- dbFetch(res)
definition <- rawToChar(data_row[1,'raw_definition'][[1]])
dbClearResult(res)

dbWriteTable(con, 'df', df)

dbDisconnect(con)


