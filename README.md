
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- devtools::rmarkdown::render("README.Rmd") -->
<!-- Rscript -e "library(knitr); knit('README.Rmd')" -->

# Locally query GenBank <img src="https://raw.githubusercontent.com/ropensci/restez/master/logo.png" height="200" align="right"/>

[![R-CMD-check](https://github.com/ropensci/restez/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/restez/actions)
[![Coverage
Status](https://coveralls.io/repos/github/ropensci/restez/badge.svg?branch=master)](https://coveralls.io/github/ropensci/restez?branch=master)
[![ROpenSci
status](https://badges.ropensci.org/232_status.svg)](https://github.com/ropensci/software-review/issues/232)
[![CRAN
downloads](http://cranlogs.r-pkg.org/badges/grand-total/restez)](https://CRAN.R-project.org/package=restez)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6806029.svg)](https://doi.org/10.5281/zenodo.6806029)
[![status](https://joss.theoj.org/papers/10.21105/joss.01102/status.svg)](https://joss.theoj.org/papers/10.21105/joss.01102)

> NOTE: Starting with v2.0.0, the database backend changed from
> [MonetDBLite](https://github.com/MonetDB/MonetDBLite-R) to
> [duckdb](https://github.com/duckdb/duckdb). Because of this change,
> restez v2.0.0 or higher **is not compatible with databases built with
> previous versions of restez**.

Download parts of [NCBI’s GenBank](https://www.ncbi.nlm.nih.gov/nuccore)
to a local folder and create a simple SQL-like database. Use ‘get’ tools
to query the database by accession IDs.
[rentrez](https://github.com/ropensci/rentrez) wrappers are available,
so that if sequences are not available locally they can be searched for
online through [Entrez](https://www.ncbi.nlm.nih.gov/books/NBK25500/).

See the [detailed
tutorials](https://docs.ropensci.org/restez/articles/restez.html) for
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

Install from CRAN:

``` r
install.packages("restez")
```

Or install the development version from r-universe:

``` r
install.packages("restez", repos = "https://ropensci.r-universe.dev")
```

Or install the development version from GitHub (requires installing the
`remotes` package first):

``` r
# install.packages("remotes")
remotes::install_github("ropensci/restez")
```

## Quick Examples

> For more detailed information on the package’s functions and detailed
> guides on downloading, constructing and querying a database, see the
> [detailed
> tutorials](https://docs.ropensci.org/restez/articles/restez.html).

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
# for reproducibility
set.seed(12345)
# get a random accession ID from the database
id <- sample(list_db_ids(), 1)
#> Warning in list_db_ids(): Number of ids returned was limited to [100].
#> Set `n=NULL` to return all ids.
# you can extract:
# sequences
seq <- gb_sequence_get(id)[[1]]
str(seq)
#>  chr "ACCGTTTTGACAGGTAACGTGAAAGCTCTTGGCAACGGGTCTTGATACCGAGTCGGGATCGGTAGTTGTTGCTTTGTTCGTTCACGATTTAAGGTCAACCTTAGCCTTGAGTTTTTCCAAGTAGT"
# definitions
def <- gb_definition_get(id)[[1]]
print(def)
#> [1] "Unidentified RNA clone M33.7"
# organisms
org <- gb_organism_get(id)[[1]]
print(org)
#> [1] "unidentified"
# or whole records
rec <- gb_record_get(id)[[1]]
cat(rec)
#> LOCUS       AF040767                 125 bp    RNA     linear   UNA 06-MAR-1998
#> DEFINITION  Unidentified RNA clone M33.7.
#> ACCESSION   AF040767
#> VERSION     AF040767.1
#> KEYWORDS    .
#> SOURCE      unidentified
#>   ORGANISM  unidentified
#>             unclassified sequences.
#> REFERENCE   1  (bases 1 to 125)
#>   AUTHORS   Pan,W.S., Ji,X.Y., Wang,H.T., Tian,K.G. and Yu,X.L.
#>   TITLE     RNA from plasma of Rhesus monkey(NO.33) which was infected by a
#>             certain patient's serum
#>   JOURNAL   Unpublished
#> REFERENCE   2  (bases 1 to 125)
#>   AUTHORS   Pan,W.S., Ji,X.Y., Wang,H.T., Tian,K.G. and Yu,X.L.
#>   TITLE     Direct Submission
#>   JOURNAL   Submitted (31-DEC-1997) Department of Applied Molecular Biology,
#>             Microbiology & Epidemiology Institution, 20 Dongdajie Street,
#>             Fengtai, Beijing 100071, China
#> FEATURES             Location/Qualifiers
#>      source          1..125
#>                      /organism="unidentified"
#>                      /mol_type="genomic RNA"
#>                      /db_xref="taxon:32644"
#>                      /clone="M33.7"
#>                      /note="from the plasma of Rhesus monkey which was infected
#>                      by plasma of a human patient"
#> ORIGIN      
#>         1 accgttttga caggtaacgt gaaagctctt ggcaacgggt cttgataccg agtcgggatc
#>        61 ggtagttgtt gctttgttcg ttcacgattt aaggtcaacc ttagccttga gtttttccaa
#>       121 gtagt
#> //
```

### Entrez wrappers

``` r
# use the entrez_* wrappers to access GB data
res <- entrez_fetch(db = 'nucleotide', id = id, rettype = 'fasta')
cat(res)
#> >AF040767.1 Unidentified RNA clone M33.7
#> ACCGTTTTGACAGGTAACGTGAAAGCTCTTGGCAACGGGTCTTGATACCGAGTCGGGATCGGTAGTTGTT
#> GCTTTGTTCGTTCACGATTTAAGGTCAACCTTAGCCTTGAGTTTTTCCAAGTAGT
# if the id is not in the local database
# these wrappers will search online via the rentrez package
res <- entrez_fetch(db = 'nucleotide', id = c('S71333.1', id),
                    rettype = 'fasta')
#> [1] id(s) are unavailable locally, searching online.
cat(res)
#> >AF040767.1 Unidentified RNA clone M33.7
#> ACCGTTTTGACAGGTAACGTGAAAGCTCTTGGCAACGGGTCTTGATACCGAGTCGGGATCGGTAGTTGTT
#> GCTTTGTTCGTTCACGATTTAAGGTCAACCTTAGCCTTGAGTTTTTCCAAGTAGT
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
page](https://docs.ropensci.org/restez/CONTRIBUTING.html).

## Licence

MIT

## Citation

Bennett et al. (2018). restez: Create and Query a Local Copy of GenBank
in R. *Journal of Open Source Software*, 3(31), 1102.
<https://doi.org/10.21105/joss.01102>

## References

Benson, D. A., Karsch-Mizrachi, I., Clark, K., Lipman, D. J., Ostell,
J., & Sayers, E. W. (2012). GenBank. *Nucleic Acids Research*,
40(Database issue), D48–D53. <https://doi.org/10.1093/nar/gkr1202>

Winter DJ. (2017) rentrez: An R package for the NCBI eUtils API. *PeerJ
Preprints* 5:e3179v2 <https://doi.org/10.7287/peerj.preprints.3179v2>

## Maintainer

[Joel Nitta](https://github.com/joelnitta)

This package previously developed and maintained by Dom Bennett

------------------------------------------------------------------------

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
