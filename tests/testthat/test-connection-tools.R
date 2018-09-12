# LIBS
library(restez)
library(testthat)

# RUNNING
restez:::cleanup()
on.exit(restez:::cleanup())
context('Testing \'connection-tools\'')
test_that('restez_ready() works', {
  expect_false(restez_ready())
  restez:::setup()
  on.exit(restez:::cleanup())
  expect_false(restez_ready())
  demo_db_create()
  expect_true(restez_ready())
})
test_that('restez_connect() works', {
  expect_error(restez_connect())
  restez:::setup()
  # must disconnect because setup connects automatically
  restez_disconnect()
  on.exit(restez:::cleanup())
  restez_connect()
  expect_true(is(restez:::connection_get(), 'MonetDBEmbeddedConnection'))
})
test_that('restez_disconnect() works', {
  expect_null(restez_disconnect())
  restez:::setup()
  # must disconnect because setup connects automatically
  restez_disconnect()
  on.exit(restez:::cleanup())
  restez_connect()
  expect_true(is(restez:::connection_get(), 'MonetDBEmbeddedConnection'))
  restez_disconnect()
  expect_error(restez:::connection_get())
})
test_that('connected() works', {
  expect_false(restez:::connected())
  restez:::setup()
  # must disconnect because setup connects automatically
  restez_disconnect()
  on.exit(restez:::cleanup())
  expect_false(restez:::connected())
  restez_connect()
  expect_true(restez:::connected())
})
test_that('has_data() works', {
  expect_false(restez:::has_data())
  restez:::setup()
  on.exit(restez:::cleanup())
  expect_false(restez:::has_data())
  demo_db_create(n = 10)
  expect_true(restez:::has_data())
})
test_that('connection_get() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  expect_true(is(restez:::connection_get(), 'MonetDBEmbeddedConnection'))
  restez:::cleanup()
  expect_error(restez:::connection_get())
})
