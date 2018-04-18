
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- devtools::rmarkdown::render("README.Rmd") -->
[restez](https://antonellilab.github.io/restez/index.html)
==========================================================

[![Build Status](https://travis-ci.org/AntonelliLab/restez.svg?branch=master)](https://travis-ci.org/AntonelliLab/restez) [![Coverage Status](https://coveralls.io/repos/github/AntonelliLab/restez/badge.svg?branch=master)](https://coveralls.io/github/AntonelliLab/restez?branch=master)

**Create and Query a Local Copy of GenBank in R.**

Download parts of NCBI's GenBank to a local folder and create a simple SQLite database. Use 'get' tools to query the database by accession IDs. [rentrez](https://github.com/ropensci/rentrez) wrappers are available, so that if sequences are not available locally they can be searched for online through [Entrez](https://www.ncbi.nlm.nih.gov/books/NBK25500/).

*For more information, visit the [restez website](https://antonellilab.github.io/restez/index.html).*

Installation
------------

You can install restez from github with:

``` r
# install.packages("devtools")
devtools::install_github("AntonelliLab/restez")
```

Quick Examples
--------------

> For more detailed tutorials, visit the [restez website](https://antonellilab.github.io/restez/index.html).

### Setup

``` r
library(restez)
# choose a location to store GB files
set_restez_path('.')
# run download function
# interactively choose GB files to download
download_genbank()
# create database
create_database()
```

### Query

``` r
library(restez)
# set a restez path
set_restez_path('.')
# create a demo database
create_demo_database(n = 10)
# contains fake sequence data of 10 records
(all_ids <- list_db_ids(db='nucleotide'))
# you can extract:
# sequences
seq <- get_sequence('demo_1')[[1]]
print(seq)
# definitions
def <- get_definition('demo_1')[[1]]
print(def)
# organisms
org <- get_organism('demo_1')[[1]]
print(org)
# or whole records
rec <- get_record('demo_1')[[1]]
cat(rec)
```

### Entrez wrappers

``` r
library(restez)
# setup as above
set_restez_path('.')
create_demo_database()
# use the entrez_* wrappers to access GB data
demo_record <- entrez_fetch(db='nucleotide', id='demo_1')
# if the id is not in the local database
# these wrappers will search online via the rentrez package
real_record <- entrez_fetch(db='nucleotide', id='S71333.1')
```

Licence
-------

MIT

References
----------

Benson, D. A., Karsch-Mizrachi, I., Clark, K., Lipman, D. J., Ostell, J., & Sayers, E. W. (2012). GenBank. *Nucleic Acids Research*, 40(Database issue), D48–D53. <http://doi.org/10.1093/nar/gkr1202>

Winter DJ. (2017) rentrez: An R package for the NCBI eUtils API. *PeerJ Preprints* 5:e3179v2 <https://doi.org/10.7287/peerj.preprints.3179v2>

Author
------

Dom Bennett
