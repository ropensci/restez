# restez v2.1.3

This update includes a small but important bug fix that otherwise would break the main functionality of the package (https://github.com/ropensci/restez/issues/47).

## Test environments

* local OS X install, R 4.2.1
* Windows Server 2022, R-devel, 64 bit (rhub)
* Windows x86_64-w64-mingw32, R-devel, 64 bit (winbuilder)
* Ubuntu Linux 20.04.1 LTS, R-release, GCC (rhub)
* Fedora Linux, R-devel, clang, gfortran (rhub)

## R CMD check results

There were no ERRORs or WARNINGs. 

The following NOTE was found on Windows (winbuilder), ubuntu-gcc-release (r-release) and fedora-clang-devel (r-devel):

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: ‘Joel H. Nitta <joelnitta@gmail.com>’

New maintainer:
  Joel H. Nitta <joelnitta@gmail.com>
Old maintainer(s):
  Joel Nitta <joelnitta@gmail.com>
```

This is correct; I fixed the Maintainer in DESCRIPTION to match the author (it was previously missing my middle initial by mistake).

The following NOTE was found on fedora-clang-devel (r-devel):

```
On fedora-clang-devel (r-devel)
  checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found
```

It seems this warning could be suppressed by setting `_R_CHECK_RD_VALIDATE_RD2HTML_` to false, but [apparently that just turns off HTML validation](https://developer.r-project.org/blosxom.cgi/R-devel/2022/04/28), which happens anyways.

## Reverse dependencies

There are no reverse dependencies currently on CRAN.

There is one reverse dependency currently on github, [phylotaR](https://github.com/ropensci/phylotaR).

I have run R CMD CHECK (via `devtools::check()`, local OS X install, R 4.2.1) and found no ERRORs or WARNINGs, and one note:

```
❯ checking package dependencies ... NOTE
  Packages suggested but not available for checking:
    'outsider', 'outsider.base'
```
[`outsider`](https://github.com/ropensci-archive/outsider) and [`outsider.base`](https://github.com/ropensci-archive/outsider.base) have also been archived and are not CRAN.
