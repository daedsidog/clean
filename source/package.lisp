;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defmacro define-clle (foreign-imports-manifest)
  `(uiop:define-package #:clean
       (:use #:cl)
     (:shadowing-import-from #:clean/mop-extensions #:defclass)
     (:reexport #:cl)
     (:use-reexport #:clean/list-extensions
                    #:clean/package-extensions
                    #:clean/string-extensions
                    #:clean/mop-extensions)
     ,@(mapcan #'identity (mapcar (lambda (ie)
                                    `((:import-from ,(car ie) ,@(cdr ie))
                                      (:export ,@(cdr ie))))
                                  foreign-imports-manifest))))

(define-clle
    ((#:alexandria . (#:with-gensyms
                      #:when-let
                      #:if-let
                      #:iota))))

(in-package #:clean)

(defmacro alias (sym alias)
  `(progn
     (setf (fdefinition ,alias) (fdefinition ,sym))
     (export ,alias)))

;; Add synonyms that adhere to the convention of having predicates be posfixed with 'p'.
(alias 'atom 'atomp)
(alias 'null 'nullp)
(alias 'eq 'eqp)
(alias 'eql 'eqlp)

#+sbcl
(progn
  (sb-ext:lock-package 'clean)
  (sb-ext:lock-package 'clean/list-extensions)
  (sb-ext:lock-package 'clean/package-extensions)
  (sb-ext:lock-package 'clean/string-extensions)
  (sb-ext:lock-package 'clean/mop-extensions))
