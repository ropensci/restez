
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
> [duckdb](https://github.com/duckdb/duckdb) in the development version,
> which should allow for submission to CRAN. Becauase of the change, the
> development verion **is not compatible with databases built with
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
#> -------------
#> restez v2.0.0
#> -------------
#> Remember to restez_path_set() and, then, restez_connect()
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
# connect, ensure safe disconnect after finishing
restez_connect()
#> Remember to run `restez_disconnect()`
# get a random accession ID from the database
id <- sample(list_db_ids(), 1)
#> Warning in list_db_ids(): Number of ids returned was limited to [100].
#> Set `n=NULL` to return all ids.
# you can extract:
# sequences
seq <- gb_sequence_get(id)[[1]]
str(seq)
#>  chr "CATGAATAAATCCTCGTATTCAGGTGAGCCTCCCTGTCCTCTCGCCTCCCCCTTTGTGTCTGTCTCTGGGAAAAGAAAAAGGTTGAAAAACCCCGGAGCACGAGGTGCGCA"| __truncated__
# definitions
def <- gb_definition_get(id)[[1]]
print(def)
#> [1] "PCR artifactual sequence for diagnosis of avian malaria"
# organisms
org <- gb_organism_get(id)[[1]]
print(org)
#> [1] "unidentified"
# or whole records
rec <- gb_record_get(id)[[1]]
cat(rec)
#> LOCUS       AF148959                 509 bp    DNA     linear   UNA 18-JUL-1999
#> DEFINITION  PCR artifactual sequence for diagnosis of avian malaria.
#> ACCESSION   AF148959
#> VERSION     AF148959.1
#> KEYWORDS    .
#> SOURCE      unidentified
#>   ORGANISM  unidentified
#>             unclassified sequences.
#> REFERENCE   1  (bases 1 to 509)
#>   AUTHORS   Jarvi,S.I., Schultz,J.J. and Atkinson,C.T.
#>   TITLE     Evaluation of a PCR test for diagnosis of avian malaria (Plasmodium
#>             relictum) in Hawaiian forest birds
#>   JOURNAL   Unpublished
#> REFERENCE   2  (bases 1 to 509)
#>   AUTHORS   Jarvi,S.I., Schultz,J.J. and Atkinson,C.T.
#>   TITLE     Direct Submission
#>   JOURNAL   Submitted (06-MAY-1999) Wildlife Disease Laboratory, PIERC,
#>             USGS-BRD, Building 343, Hawaii Vocanoes National Park, HI 96718,
#>             USA
#> FEATURES             Location/Qualifiers
#>      source          1..509
#>                      /organism="unidentified"
#>                      /mol_type="genomic DNA"
#>                      /db_xref="taxon:32644"
#>                      /note="Originated from an elepaio (Chasiempis
#>                      sandwichensis) captured in 1995 in the Alakai Wilderness
#>                      Preserve, Kauai. DNA extracted from a sample of whole
#>                      blood was used as template in a PCR reaction in which
#>                      primers 89 and 90 (Feldman RA, Freed LA, Cann RL, 1995, A
#>                      PCR test for malaria in Hawaiian forest birds, Molecular
#>                      Ecology 4:663-673) were present in equimolar amounts.
#>                      Primer 89 served as both the 5' and 3' primers in the
#>                      amplification of this product."
#> ORIGIN      
#>         1 catgaataaa tcctcgtatt caggtgagcc tccctgtcct ctcgcctccc cctttgtgtc
#>        61 tgtctctggg aaaagaaaaa ggttgaaaaa ccccggagca cgaggtgcgc aagccctcct
#>       121 ggctgcgagc gctctgcgga ggagtgagcg gctggttcgc tgtgtataaa caagtggaaa
#>       181 aggcttaaaa agcaaagcaa acgcggcggg gcagctggtt ccaggcagag cccggcactg
#>       241 ggggcacgga gcttgttatc tgagggcacc tgtgccagca gggggtgaga tccatcgcca
#>       301 agtgacagcg tggcatggga acaggaccgt ggggtgtgtg tctgagtgtg acactgggct
#>       361 gcaggcattt ccaaatcccc taatgccgag ggattctctt ctgccttctc ctgtctggct
#>       421 tgccagtttg gccctaccgg gtgagggcat ttgccctctg ctcgggcagc tcctcctccc
#>       481 cggctggcac agaatgtgca gccaccctg
#> //
```

### Entrez wrappers

``` r
# use the entrez_* wrappers to access GB data
res <- entrez_fetch(db = 'nucleotide', id = id, rettype = 'fasta')
cat(res)
#> >AF148959.1 PCR artifactual sequence for diagnosis of avian malaria
#> CATGAATAAATCCTCGTATTCAGGTGAGCCTCCCTGTCCTCTCGCCTCCCCCTTTGTGTCTGTCTCTGGG
#> AAAAGAAAAAGGTTGAAAAACCCCGGAGCACGAGGTGCGCAAGCCCTCCTGGCTGCGAGCGCTCTGCGGA
#> GGAGTGAGCGGCTGGTTCGCTGTGTATAAACAAGTGGAAAAGGCTTAAAAAGCAAAGCAAACGCGGCGGG
#> GCAGCTGGTTCCAGGCAGAGCCCGGCACTGGGGGCACGGAGCTTGTTATCTGAGGGCACCTGTGCCAGCA
#> GGGGGTGAGATCCATCGCCAAGTGACAGCGTGGCATGGGAACAGGACCGTGGGGTGTGTGTCTGAGTGTG
#> ACACTGGGCTGCAGGCATTTCCAAATCCCCTAATGCCGAGGGATTCTCTTCTGCCTTCTCCTGTCTGGCT
#> TGCCAGTTTGGCCCTACCGGGTGAGGGCATTTGCCCTCTGCTCGGGCAGCTCCTCCTCCCCGGCTGGCAC
#> AGAATGTGCAGCCACCCTG
# if the id is not in the local database
# these wrappers will search online via the rentrez package
res <- entrez_fetch(db = 'nucleotide', id = c('S71333.1', id),
                    rettype = 'fasta')
#> [1] id(s) are unavailable locally, searching online.
cat(res)
#> >AF148959.1 PCR artifactual sequence for diagnosis of avian malaria
#> CATGAATAAATCCTCGTATTCAGGTGAGCCTCCCTGTCCTCTCGCCTCCCCCTTTGTGTCTGTCTCTGGG
#> AAAAGAAAAAGGTTGAAAAACCCCGGAGCACGAGGTGCGCAAGCCCTCCTGGCTGCGAGCGCTCTGCGGA
#> GGAGTGAGCGGCTGGTTCGCTGTGTATAAACAAGTGGAAAAGGCTTAAAAAGCAAAGCAAACGCGGCGGG
#> GCAGCTGGTTCCAGGCAGAGCCCGGCACTGGGGGCACGGAGCTTGTTATCTGAGGGCACCTGTGCCAGCA
#> GGGGGTGAGATCCATCGCCAAGTGACAGCGTGGCATGGGAACAGGACCGTGGGGTGTGTGTCTGAGTGTG
#> ACACTGGGCTGCAGGCATTTCCAAATCCCCTAATGCCGAGGGATTCTCTTCTGCCTTCTCCTGTCTGGCT
#> TGCCAGTTTGGCCCTACCGGGTGAGGGCATTTGCCCTCTGCTCGGGCAGCTCCTCCTCCCCGGCTGGCAC
#> AGAATGTGCAGCCACCCTG
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
restez_disconnect()
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
