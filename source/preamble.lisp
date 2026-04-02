;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(uiop:define-package #:clean/preamble
    (:use #:cl)
  (:shadow #:equalp)
  (:import-from #:alexandria
                #:with-gensyms #:when-let #:if-let #:iota)
  (:export #:atomp        ; CLEAN aliases
           #:nullp        ;
           #:eqp          ;
           #:eqlp         ;
           #:equalp       ;
           #:equivalentp  ;
           #:with-gensyms ; Alexandria imports
           #:when-let     ;
           #:if-let       ;
           #:iota)        ;
  (:reexport #:cl))

(in-package #:clean/preamble)

(defmacro alias (sym alias)
  `(progn
     (setf (fdefinition ,alias) (fdefinition ,sym))
     (export ,alias)))

;;; Predicate aliases postfixed with 'p'

(alias 'cl:atom   'atomp)
(alias 'cl:null   'nullp)
(alias 'cl:eq     'eqp)
(alias 'cl:eql    'eqlp)
(alias 'cl:equal  'equalp)
(alias 'cl:equalp 'equivalentp)
