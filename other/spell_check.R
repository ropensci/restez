ignore <- c('restez',
            'db',
            "restez's",
            'acc',
            'booleans',
            'entrez',
            'Entrez',
            'fasta',
            'FASTA',
            'filepath',
            'GenBank',
            'nuccore',
            'REGEX',
            'rentrez',
            "rentrez's",
            'retmode',
            'Rettypes',
            'seq',
            'seqid',
            'SQLite')
            #'uilist')
devtools::spell_check(ignore = ignore, dict = 'en_GB')
vignette_files <- file.path(getwd(), 'vignettes',
                            list.files('vignettes', pattern = 'Rmd'))
for (fl in vignette_files) {
  print(fl)
  print(devtools:::spell_check_file(fl, ignore = ignore, dict = 'en_GB'))
}
