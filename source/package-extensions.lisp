;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defpackage #:ck-clle/package-extensions
  (:use #:cl)
  (:import-from #:trivial-package-local-nicknames
                #:add-package-local-nickname)
  (:export #:package-local-nicknames))

(in-package #:ck-clle/package-extensions)

#+sbcl
(eval-when (:compile-toplevel :load-toplevel :execute)
  (sb-ext:unlock-package :common-lisp))

(defun (setf package-nicknames) (nicknames package)
  "Return the package renamed after setting global NICKNAMES for PACKAGE."
  (rename-package package package nicknames))

(defun package-local-nicknames (package)
  "Return the alist of local nicknames for PACKAGE."
  (trivial-package-local-nicknames:package-local-nicknames package))

(defun (setf package-local-nicknames) (nicknames-alist package)
  "Set package-local nicknames for PACKAGE from NICKNAMES-ALIST."
  (loop :for (nickname . actual-package) :in nicknames-alist
        :do (add-package-local-nickname nickname actual-package package)))

#+sbcl
(eval-when (:compile-toplevel :load-toplevel :execute)
  (sb-ext:lock-package :common-lisp))
