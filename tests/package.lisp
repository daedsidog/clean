;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defpackage #:clean/tests
  (:export #:run-tests)
  (:use #:clean))

(in-package #:clean/tests)

(defun run-tests ()
  (clean/tests/mop-extensions-test:run-tests))
