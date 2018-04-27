library(restez)
# set a restez path with a tempdir
restez_path_set(filepath = tempdir())
# check what the set path is
(restez_path_get())
