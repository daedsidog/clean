;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defpackage #:ck-clle/package-extensions
  (:use #:cl)
  (:import-from #:trivial-package-local-nicknames
                #:add-package-local-nickname)
  (:export #:set-package-nicknames
           #:set-package-local-nicknames))

(in-package #:ck-clle/package-extensions)

(defun set-package-nicknames (package nicknames)
  "Return the package renamed after setting global NICKNAMES for PACKAGE."
  (rename-package package package nicknames))

(defun set-package-local-nicknames (package nicknames-alist)
  "Set package-local nicknames for PACKAGE from NICKNAMES-ALIST."
  (loop :for (nickname . actual-package) :in nicknames-alist
        :do (add-package-local-nickname nickname actual-package package)))
