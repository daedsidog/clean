(defmacro define-clle (imports-and-exports)
  `(uiop:define-package #:ck-clle
       (:use #:cl)
     ,@(mapcan #'identity (mapcar (lambda (ie)
                                    `((:import-from ,(car ie) ,@(cdr ie))
                                      (:export ,@(cdr ie))))
                                  imports-and-exports))))

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
  (sb-ext:lock-package 'ck-clle))
