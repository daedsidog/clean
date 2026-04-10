(defpackage #:clean/tests
  (:export #:run-tests)
  (:use #:clean))

(in-package #:clean/tests)

(defun run-tests ()
  "Run all CLEAN test suites."
  (clean/tests/mop-extensions-test:run-tests))
