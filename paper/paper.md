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

# Summary

This is a R package for downloading large sections of GenBank [@Benson2013].

Entrez [@Ostell2002]
rentrez [@Winter2017]
phylotaR [@Bennett2018]
constructing phylogenetic trees [@Eiserhardt2018]

Downloading sequences and sequence information from GenBank and related NCBI taxonomic databases is often performed via the NCBI API, Entrez. Entrez, however, has a limit on the number of requests and downloading large amounts of sequence data in this way can be inefficient. For programmatic situations where multiple Entrez calls are made, downloading may take days, weeks or even months.

This package aims to make sequence retrieval more efficient by allowing a user to download large sections of the GenBank database to their local machine and query this local database either through package specific functions or Entrez wrappers. This process is more efficient as GenBank downloads are made via NCBI’s FTP using compressed sequence files. With a good internet connection and a middle-of-the-road computer, a database comprising 20 GB of sequence information can be generated in less than 10 minutes.

# References
