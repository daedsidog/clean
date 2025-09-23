;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defpackage #:ck-clle/tests
  (:export #:run-tests)
  (:use #:cl))

(in-package #:ck-clle/tests)

(defun run-tests ()
  (ck-clle/tests/mop:run-tests))