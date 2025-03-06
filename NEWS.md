restez 2.1.5
=========================

### BUG FIXES

* gb_sequence_get() now ensures that accessions are returned in same order as
query (https://github.com/ropensci/restez/issues/64), thanks @krlmlr

* tests no longer use with_mock()
(https://github.com/ropensci/restez/issues/63), thanks @hadley

* Fix bug where a very long sequence record crashed `db_create()` ([#60](https://github.com/ropensci/restez/issues/60)), thanks @btupper

restez 2.1.4 (2023-10-25)
=========================

### BUG FIXES

* Fix bug in test due to update to duckdb ([#55](https://github.com/ropensci/restez/issues/55))


restez 2.1.3 (2022-11-09)
=========================

### BUG FIXES

* Fix error in processing GenBank release notes that arose in GenBank release 252 (#47) 

restez 2.1.2 (2022-09-05)
=========================

### BUG FIXES

* Fix spelling errors (4c0f9e48fb3e4d3351a4282d121b26f24d4241f1)
* Fix broken links (fddb4c2508975fe5bf5588da6aae5aca15f82a61)
* Other minor fixes for submission to CRAN (43795b48d6fa4ef4c7485dc0f1675d6a2e4fa574, 325b74ff3193bb94e9062bb6114a30b709324ca8)

restez 2.1.1 (2022-09-05)
=========================

### BUG FIXES

* Fix incorrect warning about `max_tries` (#45)

restez 2.1.0 (2022-08-31)
=========================

### BUG FIXES

* Fixed bug where `restez_status()` did not show correct file size (#32)
* Fixed frequent appearance of "Database is garbage-collected" warning (#33)
* Skip scanning of gzipped file if zgrep is not detected (3de4f95985c9e857eba276c323625c5c32461155)

### DOCUMENTATION
* Add "Accession filter" to "Tips and Tricks" (1e30498f91b7efd765fb24243df686e10ee16977)
* Use markdown syntax for roxygen2 (ded1466af50562b88fa1bd349fdadbc1081495d3)

### NEW FEATURES

* Change use of `restez_connect()` and `restez_disconnect()`: they are no longer user-facing, and instead get run internally for each instance of connecting to the local database. Also, connection to DB is made in read-only mode, which should allow for multiple simultaneous processes to access the DB (#33, #35)
* Add `ncbi_acc_get()` to enable easier querying of GenBank accession numbers (#37, #43)
* Add `max_tries` argument to `db_download()` to automatically re-try download in the event of a drop in internet connectivity (#36, #42)
* Add `dnabin` argument to `gb_sequence_get()` to return sequences in ape `DNAbin` format (#38, #44)

restez 2.0.0 (2022-07-07)
=========================

### BUG FIXES

* Migrate to duckdb (#18, #26)

### DOCUMENTATION

* Update to correct github repo (#28)

### NEW FEATURES

* Add option to connect to database in read-only mode (91b85f6dd24153c16be1cf74a712e5349e31c679)

### OTHER

* Switch CI from travis to github actions (9cc52e888accf489310b604b2636ffbfd0acecd7)

restez 1.1.0 (2022-06-03)
=========================

### BUG FIXES

* Fix bug where single extremely long sequence caused db_create() to die (#14)

### NEW FEATURES

* Add ability to filter database by accession number upon creation (#25)

### OTHER

* Change maintainer to [Joel Nitta](https://github.com/joelnitta)

restez 1.0.1 (2019-01-07)
=========================

### BUG FIXES

* Check internet connection in mainland China

restez 1.0.0 (2018-11-27)
=========================

### OTHER
* Post-review version of `restez` released.
* Download and query parts of GenBank from within R
