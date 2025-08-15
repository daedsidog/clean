(defmacro define-clle (foreign-imports-manifest)
  `(uiop:define-package #:ck-clle
       (:use #:cl)
     (:use-reexport #:ck-clle/list)
     (:use-reexport #:ck-clle/package)
     (:use-reexport #:ck-clle/string)
     (:use-reexport #:ck-clle/mop)
     ,@(mapcan #'identity (mapcar (lambda (ie)
                                    `((:import-from ,(car ie) ,@(cdr ie))
                                      (:export ,@(cdr ie))))
                                  foreign-imports-manifest))))

(define-clle
    ((#:alexandria #:with-gensyms
                   #:when-let
                   #:if-let
                   #:iota)))

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
  (sb-ext:lock-package 'ck-clle/list)
  (sb-ext:lock-package 'ck-clle/package)
  (sb-ext:lock-package 'ck-clle/string)
  (sb-ext:lock-package 'ck-clle/mop))