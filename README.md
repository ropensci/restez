
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- devtools::rmarkdown::render("README.Rmd") -->
<!-- Rscript -e "library(knitr); knit('README.Rmd')" -->
Locally query GenBank <img src="logo.png" height="200" align="right"/>
======================================================================

[![Build Status](https://travis-ci.org/ropensci/restez.svg?branch=master)](https://travis-ci.org/ropensci/restez) [![Coverage Status](https://coveralls.io/repos/github/ropensci/restez/badge.svg?branch=master)](https://coveralls.io/github/ropensci/restez?branch=master) [![ROpenSci status](https://badges.ropensci.org/232_status.svg)](https://github.com/ropensci/onboarding/issues/232) <!--[![CRAN downloads](http://cranlogs.r-pkg.org/badges/grand-total/restez)](https://CRAN.R-project.org/package=restez)--> [![DOI](https://zenodo.org/badge/129107980.svg)](https://zenodo.org/badge/latestdoi/129107980)

Download parts of [NCBI's GenBank](https://www.ncbi.nlm.nih.gov/nuccore) to a local folder and create a simple SQL-like database. Use 'get' tools to query the database by accession IDs. [rentrez](https://github.com/ropensci/rentrez) wrappers are available, so that if sequences are not available locally they can be searched for online through [Entrez](https://www.ncbi.nlm.nih.gov/books/NBK25500/).

See the [detailed tutorials](https://ropensci.github.io/restez/articles/restez.html) for more information.

Introduction
------------

*Vous entrez, vous rentrez et, maintenant, vous .... restez!*

Downloading sequences and sequence information from GenBank and related NCBI taxonomic databases is often performed via the NCBI API, Entrez. Entrez, however, has a limit on the number of requests and downloading large amounts of sequence data in this way can be inefficient. For programmatic situations where multiple Entrez calls are made, downloading may take days, weeks or even months.

This package aims to make sequence retrieval more efficient by allowing a user to download large sections of the GenBank database to their local machine and query this local database either through package specific functions or Entrez wrappers. This process is more efficient as GenBank downloads are made via NCBI's FTP using compressed sequence files. With a good internet connection and a middle-of-the-road computer, a database comprising 20 GB of sequence information can be generated in less than 10 minutes.

<img src="https://raw.githubusercontent.com/ropensci/restez/master/paper/outline.png" height="500" align="center"/>

Installation
------------

You can install `restez` from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("ropensci/restez")
```

Quick Examples
--------------

> For more detailed information on the package's functions and detailed guides on downloading, constructing and querying a database, see the [detailed tutorials](https://ropensci.github.io/restez/articles/restez.html).

### Setup

``` r
# Warning: running these examples may take a few minutes
library(restez)
#> -------------
#> restez v1.0.0
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
#> Remember to run `restez_disconnect()`
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
#>  chr "ATCAGAGACTTAGGACAGAACAGTCAGCGACAAACGCAAGGAAATTCTTTCTCTCCTTCCTTTCTTTCTGATTGTTTCTTCGTTCGCGGTAAAACTCACAAGTTTGCGTAA"| __truncated__
# definitions
def <- gb_definition_get(id)[[1]]
print(def)
#> [1] "Unidentified Cotton leaf curl Rajasthan virus-associated DNA clone pNDM1.5, partial sequence"
# organisms
org <- gb_organism_get(id)[[1]]
print(org)
#> [1] "unidentified Cotton leaf curl Rajasthan virus-associated DNA"
# or whole records
rec <- gb_record_get(id)[[1]]
cat(rec)
#> LOCUS       DQ415960                1129 bp    DNA     linear   UNA 07-MAY-2006
#> DEFINITION  Unidentified Cotton leaf curl Rajasthan virus-associated DNA clone
#>             pNDM1.5, partial sequence.
#> ACCESSION   DQ415960
#> VERSION     DQ415960.1
#> KEYWORDS    .
#> SOURCE      unidentified Cotton leaf curl Rajasthan virus-associated DNA
#>   ORGANISM  unidentified Cotton leaf curl Rajasthan virus-associated DNA
#>             unclassified sequences.
#> REFERENCE   1  (bases 1 to 1129)
#>   AUTHORS   Radhakrishnan,G., Malathi,V.G. and Varma,A.
#>   TITLE     Cotton leaf curl Rajasthan virus associated novel DNA molecules
#>             (NDMs)
#>   JOURNAL   Unpublished
#> REFERENCE   2  (bases 1 to 1129)
#>   AUTHORS   Radhakrishnan,G., Malathi,V.G. and Varma,A.
#>   TITLE     Direct Submission
#>   JOURNAL   Submitted (20-FEB-2006) Advanced Center for Plant Virology,
#>             Division of Plant Pathology, Indian Agricultural Research
#>             Institute, Pusa Road, New Delhi, Delhi 110012, India
#> FEATURES             Location/Qualifiers
#>      source          1..1129
#>                      /organism="unidentified Cotton leaf curl Rajasthan
#>                      virus-associated DNA"
#>                      /mol_type="genomic DNA"
#>                      /isolate="Rajasthan"
#>                      /host="cotton"
#>                      /db_xref="taxon:382345"
#>                      /clone="pNDM1.5"
#>                      /country="India"
#> ORIGIN      
#>         1 atcagagact taggacagaa cagtcagcga caaacgcaag gaaattcttt ctctccttcc
#>        61 tttctttctg attgtttctt cgttcgcggt aaaactcaca agtttgcgta aaggagtcga
#>       121 gggacacatc gcatcgtgac aggttcgtcc ctctgtccat cttgtgtaat ttaaagtaaa
#>       181 tgtagaagaa aactgccgtg gtaaggagta atgcctatga attttccaga gttgccaaat
#>       241 ttcccttgat aaaacatgta tttttgacaa catttatgcg tatatttcct tgaaattttc
#>       301 agatatttta gattaaattg cgtagaaaat tgtccgaaaa ttttggaaaa ttatattcac
#>       361 gattttccca gtaaattcgg tttttatcga aggaaacttg gcaaactctg aaggcccata
#>       421 cggcgttctt ccttagcacg gcagaaaagg cgcagaagaa ttctttcatc cgtacatact
#>       481 gttttatctc attctttatt tccgtaagct ctcccggttt ccaactcatt tctgtttgtt
#>       541 taactattta aagcagccat ccgtttaata ttaccggatg gccgcgcgat ttgaaagtgg
#>       601 acgaaaaact catgtgagat aggaaacatg ctatagtcaa gaacatgcca cgttgaaatc
#>       661 ttaaaatttt ctgttttgct tcggacaaga cgctgatagc aacatcatga gttataatgc
#>       721 ggtaccccaa gtagcaatga ccttttaaaa catttttcaa aagctctcaa aaagatgtta
#>       781 aaatgttcgt attaggaaac cctttttgta taatttctac aagtaaaatt caagggaaga
#>       841 gtgttaagca aaactctaaa aatgcgagta tcaatgtaga ttttaacctt tttttcaaac
#>       901 atttttagtg ttgacaaata cagatatttt ttacccatac attttattcc tcgtaaattt
#>       961 tacttaaaaa atagccttaa aagagtttcc taaaactgac attgtaactt ttttttataa
#>      1021 agttgtcttt ttgatatttc aagagctttt taaaagtttc tcttcaaagt cgttcttact
#>      1081 agggagacat ttttctaaca acgactctat tgcacgtgaa ttttttcga
#> //
```

### Entrez wrappers

``` r
# use the entrez_* wrappers to access GB data
res <- entrez_fetch(db = 'nucleotide', id = id, rettype = 'fasta')
cat(res)
#> >DQ415960.1 Unidentified Cotton leaf curl Rajasthan virus-associated DNA clone pNDM1.5, partial sequence
#> ATCAGAGACTTAGGACAGAACAGTCAGCGACAAACGCAAGGAAATTCTTTCTCTCCTTCCTTTCTTTCTG
#> ATTGTTTCTTCGTTCGCGGTAAAACTCACAAGTTTGCGTAAAGGAGTCGAGGGACACATCGCATCGTGAC
#> AGGTTCGTCCCTCTGTCCATCTTGTGTAATTTAAAGTAAATGTAGAAGAAAACTGCCGTGGTAAGGAGTA
#> ATGCCTATGAATTTTCCAGAGTTGCCAAATTTCCCTTGATAAAACATGTATTTTTGACAACATTTATGCG
#> TATATTTCCTTGAAATTTTCAGATATTTTAGATTAAATTGCGTAGAAAATTGTCCGAAAATTTTGGAAAA
#> TTATATTCACGATTTTCCCAGTAAATTCGGTTTTTATCGAAGGAAACTTGGCAAACTCTGAAGGCCCATA
#> CGGCGTTCTTCCTTAGCACGGCAGAAAAGGCGCAGAAGAATTCTTTCATCCGTACATACTGTTTTATCTC
#> ATTCTTTATTTCCGTAAGCTCTCCCGGTTTCCAACTCATTTCTGTTTGTTTAACTATTTAAAGCAGCCAT
#> CCGTTTAATATTACCGGATGGCCGCGCGATTTGAAAGTGGACGAAAAACTCATGTGAGATAGGAAACATG
#> CTATAGTCAAGAACATGCCACGTTGAAATCTTAAAATTTTCTGTTTTGCTTCGGACAAGACGCTGATAGC
#> AACATCATGAGTTATAATGCGGTACCCCAAGTAGCAATGACCTTTTAAAACATTTTTCAAAAGCTCTCAA
#> AAAGATGTTAAAATGTTCGTATTAGGAAACCCTTTTTGTATAATTTCTACAAGTAAAATTCAAGGGAAGA
#> GTGTTAAGCAAAACTCTAAAAATGCGAGTATCAATGTAGATTTTAACCTTTTTTTCAAACATTTTTAGTG
#> TTGACAAATACAGATATTTTTTACCCATACATTTTATTCCTCGTAAATTTTACTTAAAAAATAGCCTTAA
#> AAGAGTTTCCTAAAACTGACATTGTAACTTTTTTTTATAAAGTTGTCTTTTTGATATTTCAAGAGCTTTT
#> TAAAAGTTTCTCTTCAAAGTCGTTCTTACTAGGGAGACATTTTTCTAACAACGACTCTATTGCACGTGAA
#> TTTTTTCGA
# if the id is not in the local database
# these wrappers will search online via the rentrez package
res <- entrez_fetch(db = 'nucleotide', id = c('S71333.1', id),
                    rettype = 'fasta')
#> [1] id(s) are unavailable locally, searching online.
cat(res)
#> >DQ415960.1 Unidentified Cotton leaf curl Rajasthan virus-associated DNA clone pNDM1.5, partial sequence
#> ATCAGAGACTTAGGACAGAACAGTCAGCGACAAACGCAAGGAAATTCTTTCTCTCCTTCCTTTCTTTCTG
#> ATTGTTTCTTCGTTCGCGGTAAAACTCACAAGTTTGCGTAAAGGAGTCGAGGGACACATCGCATCGTGAC
#> AGGTTCGTCCCTCTGTCCATCTTGTGTAATTTAAAGTAAATGTAGAAGAAAACTGCCGTGGTAAGGAGTA
#> ATGCCTATGAATTTTCCAGAGTTGCCAAATTTCCCTTGATAAAACATGTATTTTTGACAACATTTATGCG
#> TATATTTCCTTGAAATTTTCAGATATTTTAGATTAAATTGCGTAGAAAATTGTCCGAAAATTTTGGAAAA
#> TTATATTCACGATTTTCCCAGTAAATTCGGTTTTTATCGAAGGAAACTTGGCAAACTCTGAAGGCCCATA
#> CGGCGTTCTTCCTTAGCACGGCAGAAAAGGCGCAGAAGAATTCTTTCATCCGTACATACTGTTTTATCTC
#> ATTCTTTATTTCCGTAAGCTCTCCCGGTTTCCAACTCATTTCTGTTTGTTTAACTATTTAAAGCAGCCAT
#> CCGTTTAATATTACCGGATGGCCGCGCGATTTGAAAGTGGACGAAAAACTCATGTGAGATAGGAAACATG
#> CTATAGTCAAGAACATGCCACGTTGAAATCTTAAAATTTTCTGTTTTGCTTCGGACAAGACGCTGATAGC
#> AACATCATGAGTTATAATGCGGTACCCCAAGTAGCAATGACCTTTTAAAACATTTTTCAAAAGCTCTCAA
#> AAAGATGTTAAAATGTTCGTATTAGGAAACCCTTTTTGTATAATTTCTACAAGTAAAATTCAAGGGAAGA
#> GTGTTAAGCAAAACTCTAAAAATGCGAGTATCAATGTAGATTTTAACCTTTTTTTCAAACATTTTTAGTG
#> TTGACAAATACAGATATTTTTTACCCATACATTTTATTCCTCGTAAATTTTACTTAAAAAATAGCCTTAA
#> AAGAGTTTCCTAAAACTGACATTGTAACTTTTTTTTATAAAGTTGTCTTTTTGATATTTCAAGAGCTTTT
#> TAAAAGTTTCTCTTCAAAGTCGTTCTTACTAGGGAGACATTTTTCTAACAACGACTCTATTGCACGTGAA
#> TTTTTTCGA
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

Contributing
------------

Want to contribute? Check the [contributing page](https://ropensci.github.io/restez/CONTRIBUTING.html).

Version
-------

Release version 1.

Licence
-------

MIT

References
----------

Benson, D. A., Karsch-Mizrachi, I., Clark, K., Lipman, D. J., Ostell, J., & Sayers, E. W. (2012). GenBank. *Nucleic Acids Research*, 40(Database issue), D48–D53. <http://doi.org/10.1093/nar/gkr1202>

Winter DJ. (2017) rentrez: An R package for the NCBI eUtils API. *PeerJ Preprints* 5:e3179v2 <https://doi.org/10.7287/peerj.preprints.3179v2>

Maintainer
----------

[Dom Bennett](https://github.com/DomBennett)
