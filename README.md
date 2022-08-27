
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- devtools::rmarkdown::render("README.Rmd") -->
<!-- Rscript -e "library(knitr); knit('README.Rmd')" -->

# Locally query GenBank <img src="https://raw.githubusercontent.com/ropensci/restez/master/logo.png" height="200" align="right"/>

[![R-CMD-check](https://github.com/ropensci/restez/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/restez/actions)
[![Coverage
Status](https://coveralls.io/repos/github/ropensci/restez/badge.svg?branch=master)](https://coveralls.io/github/ropensci/restez?branch=master)
[![ROpenSci
status](https://badges.ropensci.org/232_status.svg)](https://github.com/ropensci/onboarding/issues/232)
[![CRAN
downloads](http://cranlogs.r-pkg.org/badges/grand-total/restez)](https://CRAN.R-project.org/package=restez)
[![DOI](https://zenodo.org/badge/129107980.svg)](https://zenodo.org/badge/latestdoi/129107980)
[![status](http://joss.theoj.org/papers/6eb3ba7dddbdab8788a430eb62fc3841/status.svg)](http://joss.theoj.org/papers/6eb3ba7dddbdab8788a430eb62fc3841)

> NOTE: `restez` is no longer available on CRAN due to the archiving of
> a key dependency
> ([MonetDBLite](https://github.com/MonetDB/MonetDBLite-R)). It can
> still be installed via GitHub. The issue is being dealt with and
> hopefully a new version of `restez` will be available on CRAN soon.

> ADDITIONAL NOTE (2022-07-07): MonetDBLite has now been replaced with
> [duckdb](https://github.com/duckdb/duckdb) in version 2.0.0, which
> should allow for submission to CRAN. Because of this change, restez
> v2.0.0 or higher **is not compatible with databases built with
> previous versions of restez**.

Download parts of [NCBI’s GenBank](https://www.ncbi.nlm.nih.gov/nuccore)
to a local folder and create a simple SQL-like database. Use ‘get’ tools
to query the database by accession IDs.
[rentrez](https://github.com/ropensci/rentrez) wrappers are available,
so that if sequences are not available locally they can be searched for
online through [Entrez](https://www.ncbi.nlm.nih.gov/books/NBK25500/).

See the [detailed
tutorials](https://ropensci.github.io/restez/articles/restez.html) for
more information.

## Introduction

*Vous entrez, vous rentrez et, maintenant, vous …. restez!*

Downloading sequences and sequence information from GenBank and related
NCBI taxonomic databases is often performed via the NCBI API, Entrez.
Entrez, however, has a limit on the number of requests and downloading
large amounts of sequence data in this way can be inefficient. For
programmatic situations where multiple Entrez calls are made,
downloading may take days, weeks or even months.

This package aims to make sequence retrieval more efficient by allowing
a user to download large sections of the GenBank database to their local
machine and query this local database either through package specific
functions or Entrez wrappers. This process is more efficient as GenBank
downloads are made via NCBI’s FTP using compressed sequence files. With
a good internet connection and a middle-of-the-road computer, a database
comprising 20 GB of sequence information can be generated in less than
10 minutes.

<img src="https://raw.githubusercontent.com/ropensci/restez/master/paper/outline.png" height="500" align="center"/>

## Installation

<!--
`restez` is available via CRAN and can be installed:


```r
install.packages("restez")
```
-->

The package can currently only be installed through GitHub:

``` r
# install.packages("remotes")
remotes::install_github("ropensci/restez")
```

(It was previously available via CRAN but was archived due to a key
dependency [MonetDBLite](https://github.com/MonetDB/MonetDBLite-R) being
no longer available.)

## Quick Examples

> For more detailed information on the package’s functions and detailed
> guides on downloading, constructing and querying a database, see the
> [detailed
> tutorials](https://ropensci.github.io/restez/articles/restez.html).

### Setup

``` r
# Warning: running these examples may take a few minutes
library(restez)
# choose a location to store GenBank files
restez_path_set(rstz_pth)
```

``` r
# Run the download function
db_download()
# after download, create the local database
db_create()
```

### Query

``` r
# get a random accession ID from the database
id <- sample(list_db_ids(), 1)
#> Warning in list_db_ids(): Number of ids returned was limited to [100].
#> Set `n=NULL` to return all ids.
# you can extract:
# sequences
seq <- gb_sequence_get(id)[[1]]
str(seq)
#>  chr "GATCCATATGTATACGGAAAGCGTGTTTACCTCTTTGGTCAGATANTAACTGATGCTCACCCAATCNTNCCGTAGACCGTGCCTGATTGGGCCGGANGACCTGGGGAACGA"| __truncated__
# definitions
def <- gb_definition_get(id)[[1]]
print(def)
#> [1] "Unidentified clone A3 DNA sequence from ocean beach sand"
# organisms
org <- gb_organism_get(id)[[1]]
print(org)
#> [1] "unidentified"
# or whole records
rec <- gb_record_get(id)[[1]]
cat(rec)
#> LOCUS       AF298085                 537 bp    DNA     linear   UNA 23-NOV-2000
#> DEFINITION  Unidentified clone A3 DNA sequence from ocean beach sand.
#> ACCESSION   AF298085
#> VERSION     AF298085.1
#> KEYWORDS    .
#> SOURCE      unidentified
#>   ORGANISM  unidentified
#>             unclassified sequences.
#> REFERENCE   1  (bases 1 to 537)
#>   AUTHORS   Naviaux,R.K.
#>   TITLE     Sand DNA: a multigenomic library on the beach
#>   JOURNAL   Unpublished
#> REFERENCE   2  (bases 1 to 537)
#>   AUTHORS   Naviaux,R.K.
#>   TITLE     Direct Submission
#>   JOURNAL   Submitted (21-AUG-2000) Medicine, University of California, San
#>             Diego School of Medicine, 200 West Arbor Drive, San Diego, CA
#>             92103-8467, USA
#> FEATURES             Location/Qualifiers
#>      source          1..537
#>                      /organism="unidentified"
#>                      /mol_type="genomic DNA"
#>                      /db_xref="taxon:32644"
#>                      /clone="A3"
#>                      /note="anonymous environmental sample sequence from ocean
#>                      beach sand"
#> ORIGIN      
#>         1 gatccatatg tatacggaaa gcgtgtttac ctctttggtc agatantaac tgatgctcac
#>        61 ccaatcntnc cgtagaccgt gcctgattgg gccggangac ctggggaacg accgcgaagt
#>       121 tgtgtanctg cggaacctcn gtatnggngt nttacancaa cactgtgccc tcggccattt
#>       181 ccaggttgcc gttgtcctcc tcagnctgna tgacccatnn ataacggcca tctgccaaaa
#>       241 cccggntcac gatctgctgg gtaccgccgg ccagttccac cgtttccggc tcgtccacaa
#>       301 caccntccca atagacactg tatgcaccgg gcccccggcg ccggttctgc cgaaagaaga
#>       361 attgttgctc gtcttcnttc tcnaaatata tgctgacgtt ngccgaacga gtgagtctat
#>       421 accggatctc ggtgacgtcg gtgtcgncat cggcgtncgg nctgatccna tcgggggcga
#>       481 cgctnaatcc ctnaacagcg ggccaaaggc cangtgcatt tggccgcaac cacctgc
#> //
```

### Entrez wrappers

``` r
# use the entrez_* wrappers to access GB data
res <- entrez_fetch(db = 'nucleotide', id = id, rettype = 'fasta')
cat(res)
#> >AF298085.1 Unidentified clone A3 DNA sequence from ocean beach sand
#> GATCCATATGTATACGGAAAGCGTGTTTACCTCTTTGGTCAGATANTAACTGATGCTCACCCAATCNTNC
#> CGTAGACCGTGCCTGATTGGGCCGGANGACCTGGGGAACGACCGCGAAGTTGTGTANCTGCGGAACCTCN
#> GTATNGGNGTNTTACANCAACACTGTGCCCTCGGCCATTTCCAGGTTGCCGTTGTCCTCCTCAGNCTGNA
#> TGACCCATNNATAACGGCCATCTGCCAAAACCCGGNTCACGATCTGCTGGGTACCGCCGGCCAGTTCCAC
#> CGTTTCCGGCTCGTCCACAACACCNTCCCAATAGACACTGTATGCACCGGGCCCCCGGCGCCGGTTCTGC
#> CGAAAGAAGAATTGTTGCTCGTCTTCNTTCTCNAAATATATGCTGACGTTNGCCGAACGAGTGAGTCTAT
#> ACCGGATCTCGGTGACGTCGGTGTCGNCATCGGCGTNCGGNCTGATCCNATCGGGGGCGACGCTNAATCC
#> CTNAACAGCGGGCCAAAGGCCANGTGCATTTGGCCGCAACCACCTGC
# if the id is not in the local database
# these wrappers will search online via the rentrez package
res <- entrez_fetch(db = 'nucleotide', id = c('S71333.1', id),
                    rettype = 'fasta')
#> [1] id(s) are unavailable locally, searching online.
cat(res)
#> >AF298085.1 Unidentified clone A3 DNA sequence from ocean beach sand
#> GATCCATATGTATACGGAAAGCGTGTTTACCTCTTTGGTCAGATANTAACTGATGCTCACCCAATCNTNC
#> CGTAGACCGTGCCTGATTGGGCCGGANGACCTGGGGAACGACCGCGAAGTTGTGTANCTGCGGAACCTCN
#> GTATNGGNGTNTTACANCAACACTGTGCCCTCGGCCATTTCCAGGTTGCCGTTGTCCTCCTCAGNCTGNA
#> TGACCCATNNATAACGGCCATCTGCCAAAACCCGGNTCACGATCTGCTGGGTACCGCCGGCCAGTTCCAC
#> CGTTTCCGGCTCGTCCACAACACCNTCCCAATAGACACTGTATGCACCGGGCCCCCGGCGCCGGTTCTGC
#> CGAAAGAAGAATTGTTGCTCGTCTTCNTTCTCNAAATATATGCTGACGTTNGCCGAACGAGTGAGTCTAT
#> ACCGGATCTCGGTGACGTCGGTGTCGNCATCGGCGTNCGGNCTGATCCNATCGGGGGCGACGCTNAATCC
#> CTNAACAGCGGGCCAAAGGCCANGTGCATTTGGCCGCAACCACCTGC
#> 
#> >S71333.1 alpha 1,3 galactosyltransferase [New World monkeys, mermoset lymphoid cell line B95.8, mRNA Partial, 1131 nt]
#> ATGAATGTCAAAGGAAAAGTAATTCTGTCGATGCTGGTTGTCTCAACTGTGATTGTTGTGTTTTGGGAAT
#> ATATCAACAGCCCAGAAGGCTCTTTCTTGTGGATATATCACTCAAAGAACCCAGAAGTTGATGACAGCAG
#> TGCTCAGAAGGACTGGTGGTTTCCTGGCTGGTTTAACAATGGGATCCACAATTATCAACAAGAGGAAGAA
#> GACACAGACAAAGAAAAAGGAAGAGAGGAGGAACAAAAAAAGGAAGATGACACAACAGAGCTTCGGCTAT
#> GGGACTGGTTTAATCCAAAGAAACGCCCAGAGGTTATGACAGTGACCCAATGGAAGGCGCCGGTTGTGTG
#> GGAAGGCACTTACAACAAAGCCATCCTAGAAAATTATTATGCCAAACAGAAAATTACCGTGGGGTTGACG
#> GTTTTTGCTATTGGAAGATATATTGAGCATTACTTGGAGGAGTTCGTAACATCTGCTAATAGGTACTTCA
#> TGGTCGGCCACAAAGTCATATTTTATGTCATGGTGGATGATGTCTCCAAGGCGCCGTTTATAGAGCTGGG
#> TCCTCTGCGTTCCTTCAAAGTGTTTGAGGTCAAGCCAGAGAAGAGGTGGCAAGACATCAGCATGATGCGT
#> ATGAAGACCATCGGGGAGCACATCTTGGCCCACATCCAACACGAGGTTGACTTCCTCTTCTGCATGGATG
#> TGGACCAGGTCTTCCAAGACCATTTTGGGGTAGAGACCCTGGGCCAGTCGGTGGCTCAGCTACAGGCCTG
#> GTGGTACAAGGCAGATCCTGATGACTTTACCTATGAGAGGCGGAAAGAGTCGGCAGCATATATTCCATTT
#> GGCCAGGGGGATTTTTATTACCATGCAGCCATTTTTGGAGGAACACCGATTCAGGTTCTCAACATCACCC
#> AGGAGTGCTTTAAGGGAATCCTCCTGGACAAGAAAAATGACATAGAAGCCGAGTGGCATGATGAAAGCCA
#> CCTAAACAAGTATTTCCTTCTCAACAAACCCTCTAAAATCTTATCTCCAGAATACTGCTGGGATTATCAT
#> ATAGGCCTGCCTTCAGATATTAAAACTGTCAAGCTATCATGGCAAACAAAAGAGTATAATTTGGTTAGAA
#> AGAATGTCTGA
```

## Contributing

Want to contribute? Check the [contributing
page](https://ropensci.github.io/restez/CONTRIBUTING.html).

## Licence

MIT

## Citation

Bennett et al. (2018). restez: Create and Query a Local Copy of GenBank
in R. *Journal of Open Source Software*, 3(31), 1102.
<https://doi.org/10.21105/joss.01102>

## References

Benson, D. A., Karsch-Mizrachi, I., Clark, K., Lipman, D. J., Ostell,
J., & Sayers, E. W. (2012). GenBank. *Nucleic Acids Research*,
40(Database issue), D48–D53. <http://doi.org/10.1093/nar/gkr1202>

Winter DJ. (2017) rentrez: An R package for the NCBI eUtils API. *PeerJ
Preprints* 5:e3179v2 <https://doi.org/10.7287/peerj.preprints.3179v2>

## Maintainer

[Joel Nitta](https://github.com/joelnitta)

This package previously developed and maintained by Dom Bennett

------------------------------------------------------------------------

[![ropensci_footer](http://ropensci.org/public_images/ropensci_footer.png)](http://ropensci.org)
