## Test environments

* local OS X install, R 4.2.0
* Windows Server 2022, R-devel, 64 bit (rhub)
* Ubuntu Linux 20.04.1 LTS, R-release, GCC (rhub)
* Fedora Linux, R-devel, clang, gfortran (rhub)

## R CMD check results

There were no ERRORs or WARNINGs. 

The following NOTE was found on windows-x86_64-devel (r-devel), ubuntu-gcc-release (r-release), and fedora-clang-devel (r-devel):

```
checking CRAN incoming feasibility ... NOTE
  Maintainer: ‘Joel Nitta <joelnitta@gmail.com>’
  
  New submission
  
  Package was archived on CRAN
```

This is accurate: the package was archived on CRAN at the previous maintainer's request due to a key dependency (MonetDBLite) being archived.

The following NOTE was found on windows-x86_64-devel (r-devel):

```
checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'
```

As previously noted in [R-hub issue #503](https://github.com/r-hub/rhub/issues/503), this has been flagged as a bug in MiKTeK and likely can be safely ignored.

The following NOTE was found on fedora-clang-devel (r-devel):

```
On fedora-clang-devel (r-devel)
  checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found
```

It seems this warning could be supressed by setting `_R_CHECK_RD_VALIDATE_RD2HTML_` to false, but [apparently that just turns off HTML validation](https://developer.r-project.org/blosxom.cgi/R-devel/2022/04/28), which happens anyways.

## Reverse dependencies

There are no reverse dependencies currently on CRAN.

There is one reverse dependency currently on github, [phylotaR](https://github.com/ropensci/phylotaR).

I have run R CMD CHECK (via `devtools::check()`, local OS X install, R 4.2.0) and found no ERRORs or WARNINGs, and one note:

```
❯ checking package dependencies ... NOTE
  Packages suggested but not available for checking:
    'outsider', 'outsider.base'
```
[`outsider`](https://github.com/ropensci-archive/outsider) and [`outsider.base`](https://github.com/ropensci-archive/outsider.base) have also been archived and are not CRAN.


---

This version includes switching the local database from MonetDBLite (no longer available on CRAN) to DuckDB, [which is available on CRAN](https://cran.r-project.org/web/packages/duckdb/index.html). This should allow restez to be distributed on CRAN again. I have taken over as the new maintainer.

Thank you very much,

Joel Nitta