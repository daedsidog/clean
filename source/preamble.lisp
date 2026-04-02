(uiop:define-package #:clean/preamble
    (:use #:cl)
  (:shadow #:equalp)
  (:import-from #:alexandria
                #:with-gensyms #:when-let #:if-let #:iota)
  (:export #:atomp                    ; Predicate aliases
           #:nullp                    ;
           #:eqp                      ;
           #:eqlp                     ;
           #:equalp                   ;
           #:equivalentp              ;
           #:universal-time           ; Getter aliases
           #:decoded-time             ;
           #:internal-real-time       ;
           #:internal-run-time        ;
           #:output-stream-string     ;
           #:properties               ;
           #:setf-expansion           ;
           #:macro-character          ;
           #:dispatch-macro-character ;
           #:with-gensyms             ; Alexandria imports
           #:when-let                 ;
           #:if-let                   ;
           #:iota)                    ;
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

;;; Standard accessor functions without redundant prefix

(alias 'cl:get-universal-time           'universal-time)
(alias 'cl:get-decoded-time             'decoded-time)
(alias 'cl:get-internal-real-time       'internal-real-time)
(alias 'cl:get-internal-run-time        'internal-run-time)
(alias 'cl:get-output-stream-string     'output-stream-string)
(alias 'cl:get-properties               'properties)
(alias 'cl:get-setf-expansion           'setf-expansion)
(alias 'cl:get-macro-character          'macro-character)
(alias 'cl:get-dispatch-macro-character 'dispatch-macro-character)

(define-setf-expander macro-character (char &optional (readtable '*readtable*))
  (with-gensyms (store char-var readtable-var)
    (values (list char-var readtable-var)
            (list char readtable)
            (list store)
            `(progn (cl:set-macro-character ,char-var ,store nil ,readtable-var)
                    ,store)
            `(cl:get-macro-character ,char-var ,readtable-var))))

(define-setf-expander dispatch-macro-character
    (disp-char sub-char &optional (readtable '*readtable*))
  (with-gensyms (store disp-var sub-var readtable-var)
    (values (list disp-var sub-var readtable-var)
            (list disp-char sub-char readtable)
            (list store)
            `(progn (cl:set-dispatch-macro-character ,disp-var ,sub-var ,store ,readtable-var)
                    ,store)
            `(cl:get-dispatch-macro-character ,disp-var ,sub-var ,readtable-var))))
