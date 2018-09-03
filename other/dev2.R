devtools::load_all('~/Coding/restez')

setup()
df <- mock_gb_df_generate(n = 100)
#df <- df[ , -1]
colnames(df)


connection <- connection_get()

DBI::dbBegin(connection)
# convert version to integer
DBI::dbSendQuery(connection, "CREATE TABLE nucleotide (
            accession VARCHAR(20),
            version INT,
            organism VARCHAR(100),
            raw_definition BLOB,
            raw_sequence BLOB,
            raw_record BLOB,
            PRIMARY KEY (accession)
            )")


connection <- connection_get()
# https://www.ncbi.nlm.nih.gov/Sequin/acc.html

DBI::dbWriteTable(conn = connection, name = 'nucleotide', value = df, append = TRUE)
DBI::dbDataType(connection, df[1, 6])

cleanup()

DBI::dbGetInfo(connection)
DBI::db(connection)

gb_definition_get('demo_1')
gb_sequence_get('demo_1')
gb_definition_get('demo_1')

DBI::dbListTables(connection)


con <- DBI::dbConnect(MonetDBLite::MonetDBLite(), ":memory:")

rs <- DBI::dbSendQuery(con, "SELECT 1 AS a, 2 AS b")
DBI::dbColumnInfo(rs)
DBI::dbFetch(rs)
DBI::dbClearResult(rs)
DBI::dbDisconnect(con)
