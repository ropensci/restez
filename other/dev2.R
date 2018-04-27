library(restez)

restez_path_set(filepath = tempdir())
# create demo database
create_demo_database(n = 100)
# in the demo, IDs are 'demo_1', 'demo_2' ...
(get_sequence(id = 'demo_1'))

id <- c('demo_1', 'demo_2')

res <- rentrez::entrez_summary(db = 'nucleotide', id = 'S71333')
rentrez:::parse_esummary()

db = 'nucleotide'
id = 'S71333'
web_history = NULL
version = "2.0"
always_return_list = FALSE
retmode = 'json'
config = NULL
args <- c(list("esummary", db = db, config = config, retmode = retmode,
               version = version), 'id' = id)

identifiers <- rentrez:::id_or_webenv()
identifiers <- id

response <- do.call(rentrez:::make_entrez_query, args)
cat(response)
rentrez:::parse_response
