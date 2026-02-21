;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defmacro define-clle (foreign-imports-manifest)
  `(uiop:define-package #:ck-clle
       (:use #:cl)
     (:use-reexport #:ck-clle/list-extensions
                    #:ck-clle/package-extensions
                    #:ck-clle/string-extensions
                    #:ck-clle/mop-extensions)
     ,@(mapcan #'identity (mapcar (lambda (ie)
                                    `((:import-from ,(car ie) ,@(cdr ie))
                                      (:export ,@(cdr ie))))
                                  foreign-imports-manifest))))

(define-clle
    ((#:alexandria . (#:with-gensyms
                      #:when-let
                      #:if-let
                      #:iota))
     (#:hash-set   . (#:make-hash-set
                      #:hash-set-p
                      #:list-to-hs
                      #:hs-insert
                      #:hs-ninsert
                      #:hs-remove
                      #:hs-nremove
                      #:hs-remove-if
                      #:hs-nremove-if
                      #:hs-remove-if-not
                      #:hs-nremove-if-not
                      #:hs-memberp
                      #:hs-count
                      #:hs-empty-p
                      #:hs-map
                      #:hs-filter
                      #:hs-to-list
                      #:hs-first
                      #:hs-pop
                      #:hs-npop
                      #:hs-union
                      #:hs-nunion
                      #:hs-intersection
                      #:hs-nintersection
                      #:hs-difference
                      #:hs-ndifference
                      #:hs-symmetric-difference
                      #:hs-subsetp
                      #:hs-supersetp
                      #:hs-any
                      #:hs-all
                      #:hs-powerset
                      #:hs-cartesian-product))))

(in-package #:ck-clle)

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
  (sb-ext:lock-package 'ck-clle)
  (sb-ext:lock-package 'ck-clle/list-extensions)
  (sb-ext:lock-package 'ck-clle/package-extensions)
  (sb-ext:lock-package 'ck-clle/string-extensions)
  (sb-ext:lock-package 'ck-clle/mop-extensions))
