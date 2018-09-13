
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- devtools::rmarkdown::render("README.Rmd") -->
<!-- Rscript -e "library(knitr); knit('README.Rmd')" -->
Locally query GenBank <img src="logo.png" height="200" align="right"/>
======================================================================

[![Build Status](https://travis-ci.org/AntonelliLab/restez.svg?branch=master)](https://travis-ci.org/AntonelliLab/restez) [![Coverage Status](https://coveralls.io/repos/github/AntonelliLab/restez/badge.svg?branch=master)](https://coveralls.io/github/AntonelliLab/restez?branch=master) [![DOI](https://zenodo.org/badge/129107980.svg)](https://zenodo.org/badge/latestdoi/129107980)

Download parts of [NCBI's GenBank](https://www.ncbi.nlm.nih.gov/nuccore) to a local folder and create a simple SQLite database. Use 'get' tools to query the database by accession IDs. [rentrez](https://github.com/ropensci/rentrez) wrappers are available, so that if sequences are not available locally they can be searched for online through [Entrez](https://www.ncbi.nlm.nih.gov/books/NBK25500/). Visit the [website](https://antonellilab.github.io/restez/index.html) to find out more.

Introduction
------------

*Vous entrez, vous rentrez et, maintenant, vous .... restez!*

Downloading sequences and sequence information from GenBank and related NCBI taxonomic databases is often performed via the NCBI API, Entrez. Entrez, however, has a limit on the number of requests and downloading large amounts of sequence data in this way can be inefficient. For programmatic situations where multiple Entrez calls are made, downloading may take days, weeks or even months.

This package aims to make sequence retrieval more efficient by allowing a user to download large sections of the GenBank database to their local machine and query this local database either through package specific functions or Entrez wrappers. This process is more efficient as GenBank downloads are made via NCBI's FTP using compressed sequence files. With a good internet connection and a middle-of-the-road computer, a database comprising 20 GB of sequence information can be generated in less than 10 minutes.

<img src="https://raw.githubusercontent.com/AntonelliLab/restez/master/paper/outline.png" height="500" align="center"/>

**For more detailed information on the pacakge's functions and detailed guides on downloading, constructing and querying a database, visit the [restez website](https://antonellilab.github.io/restez/index.html).**

Installation
------------

You can install restez from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("AntonelliLab/restez")
```

Quick Examples
--------------

> For more detailed tutorials, visit the [restez website](https://antonellilab.github.io/restez/index.html).

### Setup

``` r
# Warning: running these examples may take a few minutes
library(restez)
#> -------------
#> restez v0.1.0
#> -------------
#> Remember to restez_path_set() and, then, restez_connect()
# choose a location to store GenBank files
restez_path_set(tempdir())
#> ... Creating '/var/folders/ps/g89999v12490dmp0jnsfmykm0043m3/T//RtmpdUEnD6/restez'
#> ... Creating '/var/folders/ps/g89999v12490dmp0jnsfmykm0043m3/T//RtmpdUEnD6/restez/downloads'
# Running the download function ....
# interactively choose GenBank files to download
# e.g. 20 is smallest
db_download(preselection = '20')
#> ───────────────────────────────────────────────────────────────────────────────────────────────
#> Looking up latest GenBank release ...
#> ... release number 227
#> ... found 3164 sequence files
#> ───────────────────────────────────────────────────────────────────────────────────────────────
#> Which sequence file types would you like to download?
#> Choose from those listed below:
#> ● 1  -  'Bacterial' (520 files and 118 GB)
#> ● 2  -  'EST (expressed sequence tag)' (485 files and 242 GB)
#> ● 3  -  'Constructed' (369 files and 84 GB)
#> ● 4  -  'Patent' (337 files and 77.3 GB)
#> ● 5  -  'GSS (genome survey sequence)' (308 files and 117 GB)
#> ● 6  -  'TSA (transcriptome shotgun assembly)' (234 files and 53.9 GB)
#> ● 7  -  'Plant sequence entries (including fungi and algae),' (198 files and 42.6 GB)
#> ● 8  -  'HTGS (high throughput genomic sequencing)' (155 files and 36.7 GB)
#> ● 9  -  'Invertebrate' (108 files and 23.8 GB)
#> ● 10  -  'Environmental sampling' (103 files and 23.9 GB)
#> ● 11  -  'Other vertebrate' (94 files and 19.3 GB)
#> ● 12  -  'Primate' (59 files and 13.7 GB)
#> ● 13  -  'Viral' (57 files and 12.9 GB)
#> ● 14  -  'Other mammalian' (55 files and 9.41 GB)
#> ● 15  -  'Rodent' (31 files and 7.3 GB)
#> ● 16  -  'STS (sequence tagged site)' (20 files and 4.45 GB)
#> ● 17  -  'HTC (high throughput cDNA sequencing)' (15 files and 3.42 GB)
#> ● 18  -  'Synthetic and chimeric' (10 files and 2.41 GB)
#> ● 19  -  'Phage' (5 files and 1.06 GB)
#> ● 20  -  'Unannotated' (1 files and 0.00108 GB)
#> Provide one or more numbers separated by spaces.
#> e.g. to download all Mammal sequences type:"12 14 15" followed by Enter
#> Which files would you like to download?
#> ───────────────────────────────────────────────────────────────────────────────────────────────
#> You've selected a total of 1 file(s) and 0.00108 GB of uncompressed data. These represent: 
#> ● 'Unannotated'
#> 
#> Based on stated GenBank files sizes, we estimate ... 
#> ... 0.000216 GB for  compressed, downloaded files
#> ... 0.00132 GB for the SQL database
#> Leading to a total of 0.00153 GB
#> 
#> Please note, the real sizes of the database and its downloads cannot be accurately predicted beforehand. These are just estimates, actual sizes may differ up to 0-5GB.
#> 
#> Is this OK?
#> ───────────────────────────────────────────────────────────────────────────────────────────────
#> Downloading ...
#> ... 'gbuna1.seq' (1/1)
#> Done. Enjoy your day.
#> [1] TRUE
# connect, ensure safe disconnect after finishing
restez_connect()
#> Remember to run `restez_disconnect()`
# after download, create the local database
db_create()
#> Adding 1 file(s) to the database ...
#> ... 'gbuna1.seq.gz'(1 / 1)
#> Done.
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
print(seq)
#> [1] "GATCCGGCGCTCGCCTCGTGACGGCGCCGGCTCATGGCAACGCCGCCAGGGCGCCGCGCAGGCCCGGTTCGGGGCTCGCGGGCACCGGCGGCGCCCGGTCACCCGCCTCCTCGGCAAGACCGCCGATGGTGGAGCAGGTGCACAGCACCACATCCTCCAGGCGCGCGGCTTCGGCGACGGCCGCGCCCACCGCCCTGTGCACGGCGGTGTCCTGGATGCCCCGGGTACGGGCGTCGTGCAGGAGATCCGCACGCACCAGGTGGCGCGCGCTGTTTCCGGGTGCCAGCTCCCGCAGCAGGGCGTCGAGCGCCTGGACATGGACGGGGGCCGTATGCACGAAAACCAGCTGTGACATATGCGCATGATGCCTCAGGGCGTGACGCCGGAGCCAGGAATCCCTGGAAGAGCATTTACATAGACATAAAGATATGTTGATATCCNGCCTTCCGCGATTCCACCGGGATGATCACCATGGCCAGCACCACCGGTACCCCCTGCATGGACTCAATCTTNGANGACACCCCCCGCCGCCTGGCAGCCGTCTGCCATGCCGTTCACGCCGCTGCGGCCCTGGACTGTCTTNNANCTGTTCCGCGGCANTGANGGCAGGGCTGGATTCACATGCTGGCGNCTTGCCCGTNGTNCCGTTTTTTGGGACTACGGGCCGNGGAGACCGGATCCACCTGAA"
# definitions
def <- gb_definition_get(id)[[1]]
print(def)
#> [1] "Unidentified clone B17 DNA sequence from ocean beach sand"
# organisms
org <- gb_organism_get(id)[[1]]
print(org)
#> [1] "unidentified"
# or whole records
rec <- gb_record_get(id)[[1]]
cat(rec)
#> LOCUS       AF298095                 688 bp    DNA     linear   UNA 23-NOV-2000
#> DEFINITION  Unidentified clone B17 DNA sequence from ocean beach sand.
#> ACCESSION   AF298095
#> VERSION     AF298095.1
#> KEYWORDS    .
#> SOURCE      unidentified
#>   ORGANISM  unidentified
#>             unclassified sequences.
#> REFERENCE   1  (bases 1 to 688)
#>   AUTHORS   Naviaux,R.K.
#>   TITLE     Sand DNA: a multigenomic library on the beach
#>   JOURNAL   Unpublished
#> REFERENCE   2  (bases 1 to 688)
#>   AUTHORS   Naviaux,R.K.
#>   TITLE     Direct Submission
#>   JOURNAL   Submitted (21-AUG-2000) Medicine, University of California, San
#>             Diego School of Medicine, 200 West Arbor Drive, San Diego, CA
#>             92103-8467, USA
#> FEATURES             Location/Qualifiers
#>      source          1..688
#>                      /organism="unidentified"
#>                      /mol_type="genomic DNA"
#>                      /db_xref="taxon:32644"
#>                      /clone="B17"
#>                      /note="anonymous environmental sample sequence from ocean
#>                      beach sand"
#> ORIGIN      
#>         1 gatccggcgc tcgcctcgtg acggcgccgg ctcatggcaa cgccgccagg gcgccgcgca
#>        61 ggcccggttc ggggctcgcg ggcaccggcg gcgcccggtc acccgcctcc tcggcaagac
#>       121 cgccgatggt ggagcaggtg cacagcacca catcctccag gcgcgcggct tcggcgacgg
#>       181 ccgcgcccac cgccctgtgc acggcggtgt cctggatgcc ccgggtacgg gcgtcgtgca
#>       241 ggagatccgc acgcaccagg tggcgcgcgc tgtttccggg tgccagctcc cgcagcaggg
#>       301 cgtcgagcgc ctggacatgg acgggggccg tatgcacgaa aaccagctgt gacatatgcg
#>       361 catgatgcct cagggcgtga cgccggagcc aggaatccct ggaagagcat ttacatagac
#>       421 ataaagatat gttgatatcc ngccttccgc gattccaccg ggatgatcac catggccagc
#>       481 accaccggta ccccctgcat ggactcaatc ttngangaca ccccccgccg cctggcagcc
#>       541 gtctgccatg ccgttcacgc cgctgcggcc ctggactgtc ttnnanctgt tccgcggcan
#>       601 tganggcagg gctggattca catgctggcg ncttgcccgt ngtnccgttt tttgggacta
#>       661 cgggccgngg agaccggatc cacctgaa
#> //
```

### Entrez wrappers

``` r
# use the entrez_* wrappers to access GB data
res <- entrez_fetch(db = 'nucleotide', id = id, rettype = 'fasta')
cat(res)
#> >AF298095.1 Unidentified clone B17 DNA sequence from ocean beach sand
#> GATCCGGCGCTCGCCTCGTGACGGCGCCGGCTCATGGCAACGCCGCCAGGGCGCCGCGCAGGCCCGGTTC
#> GGGGCTCGCGGGCACCGGCGGCGCCCGGTCACCCGCCTCCTCGGCAAGACCGCCGATGGTGGAGCAGGTG
#> CACAGCACCACATCCTCCAGGCGCGCGGCTTCGGCGACGGCCGCGCCCACCGCCCTGTGCACGGCGGTGT
#> CCTGGATGCCCCGGGTACGGGCGTCGTGCAGGAGATCCGCACGCACCAGGTGGCGCGCGCTGTTTCCGGG
#> TGCCAGCTCCCGCAGCAGGGCGTCGAGCGCCTGGACATGGACGGGGGCCGTATGCACGAAAACCAGCTGT
#> GACATATGCGCATGATGCCTCAGGGCGTGACGCCGGAGCCAGGAATCCCTGGAAGAGCATTTACATAGAC
#> ATAAAGATATGTTGATATCCNGCCTTCCGCGATTCCACCGGGATGATCACCATGGCCAGCACCACCGGTA
#> CCCCCTGCATGGACTCAATCTTNGANGACACCCCCCGCCGCCTGGCAGCCGTCTGCCATGCCGTTCACGC
#> CGCTGCGGCCCTGGACTGTCTTNNANCTGTTCCGCGGCANTGANGGCAGGGCTGGATTCACATGCTGGCG
#> NCTTGCCCGTNGTNCCGTTTTTTGGGACTACGGGCCGNGGAGACCGGATCCACCTGAA
# if the id is not in the local database
# these wrappers will search online via the rentrez package
res <- entrez_fetch(db = 'nucleotide', id = c('S71333.1', id),
                    rettype = 'fasta')
#> [1] id(s) are unavailable locally, searching online.
cat(res)
#> >AF298095.1 Unidentified clone B17 DNA sequence from ocean beach sand
#> GATCCGGCGCTCGCCTCGTGACGGCGCCGGCTCATGGCAACGCCGCCAGGGCGCCGCGCAGGCCCGGTTC
#> GGGGCTCGCGGGCACCGGCGGCGCCCGGTCACCCGCCTCCTCGGCAAGACCGCCGATGGTGGAGCAGGTG
#> CACAGCACCACATCCTCCAGGCGCGCGGCTTCGGCGACGGCCGCGCCCACCGCCCTGTGCACGGCGGTGT
#> CCTGGATGCCCCGGGTACGGGCGTCGTGCAGGAGATCCGCACGCACCAGGTGGCGCGCGCTGTTTCCGGG
#> TGCCAGCTCCCGCAGCAGGGCGTCGAGCGCCTGGACATGGACGGGGGCCGTATGCACGAAAACCAGCTGT
#> GACATATGCGCATGATGCCTCAGGGCGTGACGCCGGAGCCAGGAATCCCTGGAAGAGCATTTACATAGAC
#> ATAAAGATATGTTGATATCCNGCCTTCCGCGATTCCACCGGGATGATCACCATGGCCAGCACCACCGGTA
#> CCCCCTGCATGGACTCAATCTTNGANGACACCCCCCGCCGCCTGGCAGCCGTCTGCCATGCCGTTCACGC
#> CGCTGCGGCCCTGGACTGTCTTNNANCTGTTCCGCGGCANTGANGGCAGGGCTGGATTCACATGCTGGCG
#> NCTTGCCCGTNGTNCCGTTTTTTGGGACTACGGGCCGNGGAGACCGGATCCACCTGAA
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

Want to contribute? Check the [contributing page](https://antonellilab.github.io/restez/CONTRIBUTING.html).

Version
-------

Pre-release version 0 for review.

Licence
-------

MIT

References
----------

Benson, D. A., Karsch-Mizrachi, I., Clark, K., Lipman, D. J., Ostell, J., & Sayers, E. W. (2012). GenBank. *Nucleic Acids Research*, 40(Database issue), D48–D53. <http://doi.org/10.1093/nar/gkr1202>

Winter DJ. (2017) rentrez: An R package for the NCBI eUtils API. *PeerJ Preprints* 5:e3179v2 <https://doi.org/10.7287/peerj.preprints.3179v2>

Author
------

[Dom Bennett](https://github.com/DomBennett)
