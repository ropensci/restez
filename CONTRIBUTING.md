# Contributing

You are very welcome to help out in the development of restez. The NCBI databases and resources are vast, it is not possible
for a single person from a single discpline within the biological sciences to effectively realise all of what NCBI has to offer.
Restez needs your help!

If you have any ideas for future features than please add them to the [issues page](https://github.com/ropensci/restez/issues).
If you have the guile, time and inspriation to add those features yourself, then please fork and send a pull request.

## Areas for possible contribution

### Protein database

Currently restez only downloads the nucleotide database (synonyms: GenBank, nuccore). All of the restez functions for downloading,
creating and querying the nucleotide database could easily be copied and reengineered for working with a protein database.

### Taxonomy

Likewise the taxonomic database could also be downloaded and integrated into the restez framework. The taxonomic database is,
however, stored different from the nucleotide given its unique nature. Better would be to make use of currently existing packages
(e.g taxizedb) and integrate them into restez. This may allow users to have simple entrez_search functions when looking up
sequence ids (e.g. retreiving all sequences associated with a particular taxonomic group.)

### Retmodes

Restez tries to recreate the output from rentrez wrappers as best it can. For any queries with retmodes that are not text-based
(e.g. xml, feature tables), however, restez must search online. This is because all NCBI FTP downloads are text based 'flatfiles'.
Currently, the only way to recreate non-text based data would be to convert the download flatfiles to other formats upon request.
This is far from an ideal scenario as there would be no guarrantee that a restez result would match a rentrez result for the same
query.

## How to contribute

To contribute you will need a GitHub account and to have basic knowledge of the R language. You can then create a fork of the
repo in your own GitHub account and download the repository to your local machine. `devtools` is recommended.

```r
devtools::install_github('[your account]/restez')
```

All new functions must be tested. For every new file in `R/`, a new test file must be created in `tests/testthat/`. To test the
package and make sure it meets CRAN guidelines use `devtools`. 

```r
devtools::test()
```

For help, refer to Hadley Wickham's book, [R packages](http://r-pkgs.had.co.nz/).

## Style guide

Restez is part of ROpenSci. This means the package and its code should meet ROpenSci style and
standards. For example, function names should be all lowercase, separated by underscores and the last word should, ideally, be
a verb.

```
# e.g.
species_ids_retrieve()  # good
sppIDs()                # not great
sp.IDS_part2()          # really bad
sigNXTprt.p()           # awful
```

It is best to make functions small, with specific names. Feel free to break up code into multiple separate files (e.g. tools,
helper functions, stages ...). For more details and better explanations refer to the ROpenSci [guide](https://github.com/ropensci/onboarding/blob/master/packaging_guide.md).
