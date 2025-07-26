(defpackage #:ck-clle/package
  (:use #:cl)
  (:export #:set-package-nicknames))

(in-package #:ck-clle/package)

(defun set-package-nicknames (package nicknames)
  (rename-package package package nicknames))