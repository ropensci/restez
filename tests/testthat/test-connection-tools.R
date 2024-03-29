# LIBS
library(testthat)

# RUNNING
cleanup()
context('Testing \'connection-tools\'')
test_that('restez_ready() works', {
  on.exit(cleanup())
  expect_false(restez_ready())
  setup()
  demo_db_create()
  expect_true(restez_ready())
  cleanup()
})
test_that('restez_connect() works', {
  on.exit({
    restez_disconnect()
    cleanup()
    })
  expect_error(restez_connect())
  restez_disconnect()
  setup()
  restez_connect()
  expect_true(is(connection_get(), 'duckdb_connection'))
  restez_disconnect()
  cleanup()
})
test_that('restez_connect() works in read-only mode', {
  on.exit({
    cleanup()
    restez_disconnect()
    })
  setup()
  demo_db_create(n = 10)
  restez_connect(read_only = TRUE)
  expect_true(is(connection_get(), 'duckdb_connection'))
  restez_disconnect()
  cleanup()
})
test_that('restez_disconnect() works', {
  on.exit({
    cleanup()
    restez_disconnect()
    })
  expect_null(restez_disconnect())
  setup()
  restez_connect()
  expect_true(is(connection_get(), 'duckdb_connection'))
  restez_disconnect()
  expect_error(connection_get())
  cleanup()
})
test_that('connected() works', {
  on.exit({
    cleanup()
    restez_disconnect()
    })
  expect_false(connected())
  setup()
  expect_false(connected())
  restez_connect()
  expect_true(connected())
  cleanup()
  restez_disconnect()
})
test_that('has_data() works', {
  on.exit({
    cleanup()
    restez_disconnect()
    })
  expect_false(has_data())
  setup()
  expect_false(has_data())
  demo_db_create(n = 10)
  expect_true(has_data())
  cleanup()
  restez_disconnect()
})
test_that('connection_get() works', {
  on.exit({
    cleanup()
    restez_disconnect()
    })
  setup()
  restez_connect()
  expect_true(is(connection_get(), 'duckdb_connection'))
  restez_disconnect()
  cleanup()
  expect_error(connection_get())
})
cleanup()
