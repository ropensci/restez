devtools::load_all('~/Coding/restez')
restez_path_set('~/Desktop')
db_delete(everything = TRUE)
restez_path_set('~/Desktop')
file_download(fl = 'gbenv84.seq')
seq_file <- 'gbenv84.seq.gz'
flpth <- file.path(dwnld_path_get(), seq_file)
records <- flatfile_read(flpth = flpth)

restez_connect()
db_create()

length(records)
infoparts <- unname(vapply(X = records, FUN = extract_inforecpart,
                           FUN.VALUE = character(1)))
for (i in seq_along(records)) {
  infopart <- extract_inforecpart(records[[i]])
}
record <- records[[i]]

x <- c("Ekstr\xf8m", "J\xf6reskog", "bi\xdfchen Z\xfcrcher")
nchar(iconv(x = x, from = 'latin1', to = 'latin1', sub = "-"))

nchar(iconv(x = record, to = 'Latin-1', sub = "-"))

keyword <- 'ACCESSION'
end_pattern <- '\n'
start_index <- regexpr(pattern = keyword, text = record)
if (start_index == -1) {
  return(NULL)
}
nchar(record)

part_record <- substr(x = record, start = start_index, stop = nchar(record))
end_index <- regexpr(pattern = end_pattern, text = part_record)
if (end_index == -1) {
  return(NULL)
}
res  <- substr(x = part_record, start = 1, stop = end_index - 1)
res <- sub(pattern = paste0(keyword, '\\s+'), replacement = '', x = res)
res



db_download(preselection = '15')
restez_status()
restez_connect()
db_create()
restez_status(gb_check = FALSE)
restez_disconnect()
