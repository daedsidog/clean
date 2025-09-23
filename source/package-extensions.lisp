;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defpackage #:ck-clle/package-extensions
  (:use #:cl)
  (:export #:set-package-nicknames))

(in-package #:ck-clle/package-extensions)

(defun set-package-nicknames (package nicknames)
  (rename-package package package nicknames))