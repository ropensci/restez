---
title: 'restez: Create and Query a Local Copy of GenBank in R'
tags:
  - GenBank
  - nucleotides
  - R
authors:
 - name: Dominic J. Bennett
   orcid: 0000-0003-2722-1359
   affiliation: "1, 2"
affiliations:
 - name: Gothenburg Global Biodiversity Centre, Box 461, SE-405 30 Gothenburg, Sweden
   index: 1
 - name: Department of Biological and Environmental Sciences, University of Gothenburg, Box 461, SE-405 30 Gothenburg, Sweden
   index: 2
date: 19 June 2018
bibliography: paper.bib
---

#Summary

Downloading sequences and sequence information from GenBank [@Benson2013] and related NCBI databases is often performed via the NCBI API, Entrez [@Ostell2002]. Entrez, however, has a limit on the number of requests and downloading large amounts of sequence data in this way can be inefficient. For programmatic situations where multiple Entrez calls are made, downloading may take days, weeks or even months and could even result in a user being blacklisted from the NCBI services.

The `restez` package [@restez_z] aims to make sequence retrieval more efficient by allowing a user to download large sections of the GenBank database to their local machine and query this local database instead. This process is more efficient as GenBank downloads are made via NCBI’s FTP using compressed sequence files. With a good internet connection and a middle-of-the-road computer, a database comprising 20 GB of sequence information can be generated in less than 10 minutes.


##Rentrez integration

`rentrez` [@Winter2017] is a popular R package for querying via Entrez in R. To maximise the transmissability of `restez`, the package comes with `rentrez` wrapper functions that take the exact same arguments as the `rentrez` equivalents. Whenever a wrapper function is called the local database copy is searched first. If IDs are missing in the local database, secondarily, a call to Entrez is made via the internet. The amount of recoding of a user is thus reduced. At a minimum, a user currently using `rentrez` will only need to create a local GenBank copy and call `restez` instead of `rentrez` in their scripts and packages.

##A worked example

`phylotaR` [@Bennett2018] is an R package for identifying orthologous sequence clusters in GenBank as a first step in a phylogenetic analysis. Because the package runs an automated pipeline, multiple queries to GenBank via Entrez are made using the `rentrez` package. As a result, for large taxonomic groups containing well-sequenced species the pipeline can take a long time to complete.

```{r}
library(phylotaR)
# run phylotaR pipeline for New World Monkeys
txid <- 9479  # taxonomic ID
setup(wd = 'nw_monkeys', txid = txid)
run(wd = wd)
# ^ takes around 40 minutes
```

We can download and create a local copy of the primates GenBank locally and re-run the above code with a library call to `restez` for massive speed-up gains.

```{r}
# setup database
library(restez)
restez_path_set(filepath = 'restez_db')
db_download(db = 'nucleotide')
db_create(db = 'nucleotide')
```
```{r}
# run phylotaR again
library(phylotaR)
library(restez)
txid <- 9479
setup(wd = 'nw_monkeys', txid = txid)
run(wd = wd)
# ^ takes around 5 minutes
```

For more examples and tutorials, see the `restez` GitHub page [@restez_gh].

# References
