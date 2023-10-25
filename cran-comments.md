# restez v2.1.4

This update includes a bug fix to account for an update to
one of the main dependencies, duckdb ([#55](https://github.com/ropensci/restez/issues/55))

## Test environments

* local OS X install, R 4.3.1
* Windows Server 2022, R-devel, 64 bit (rhub)
* Windows x86_64-w64-mingw32, R-devel, 64 bit (winbuilder)
* Ubuntu Linux 20.04.1 LTS, R-release, GCC (rhub)
* Fedora Linux, R-devel, clang, gfortran (rhub)

## R CMD check results

There were no ERRORs or WARNINGs. 

The following NOTE was found on ubuntu-gcc-release (r-release) and fedora-clang-devel (r-devel):

```
On fedora-clang-devel (r-devel)
  checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found
```

It seems this warning could be suppressed by setting `_R_CHECK_RD_VALIDATE_RD2HTML_` to false, but [apparently that just turns off HTML validation](https://developer.r-project.org/blosxom.cgi/R-devel/2022/04/28), which happens anyways.

The following NOTE was found on Windows (rhub):

```
* checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''

* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

These are both R-hub bugs that have not yet been resolved (https://github.com/r-hub/rhub/issues/560, https://github.com/r-hub/rhub/issues/503)

The following NOTE was found on Windows (winbuilder):

```
Found the following (possibly) invalid URLs:
  URL: https://ropensci.org
    From: README.md
    Status: Error
    Message: Recv failure: Connection was reset
```

This seems to be a false positive. https://ropensci.org is a valid URL.

## Reverse dependencies

There are no reverse dependencies currently on CRAN.

There is one reverse dependency currently on github, [phylotaR](https://github.com/ropensci/phylotaR).

I have run R CMD CHECK (via `devtools::check()`, local OS X install, R 4.2.1) and found no ERRORs or WARNINGs, and one note about sub-directories of 1Mb or more for phylotaR (not restez)
