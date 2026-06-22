(uiop:define-package #:clean/aliases
  (:use #:cl)
  (:shadow #:eq #:equal #:null #:atom #:equalp #:make-hash-table)
  (:import-from #:alexandria
                #:with-gensyms #:when-let #:if-let #:iota)
  (:export #:atom                     ; Type specifiers
           #:null                     ;
           #:atomp                    ; Predicate aliases
           #:nullp                    ;
           #:eqp                      ;
           #:eqlp                     ;
           #:equalp                   ;
           #:equivalentp              ;
           #:everyp                   ;
           #:notanyp                  ;
           #:noteveryp                ;
           #:string-equal-p           ;
           #:string-not-equal-p       ;
           #:char-equal-p             ;
           #:char-not-equal-p         ;
           #:make-hash-table          ; Hash table constructor
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

(in-package #:clean/aliases)

(unexport '(eq
            equal
            every
            notany
            notevery
            string-equal
            string-not-equal
            char-equal
            char-not-equal
            get-universal-time
            get-decoded-time
            get-internal-real-time
            get-internal-run-time
            get-output-stream-string
            get-properties
            get-setf-expansion
            get-macro-character
            get-dispatch-macro-character))

(defmacro define-alias (name lambda-list &body body)
  "Define and export an inline wrapper forwarding to a Common Lisp function."
  `(progn
     (declaim (inline ,name))
     (defun ,name ,lambda-list ,@body)
     (export ',name)))

;;; Predicate aliases postfixed with 'p'

(deftype null () 'cl:null)
(deftype atom () 'cl:atom)

(define-alias atomp       (object) (cl:atom object))
(define-alias nullp       (object) (cl:null object))
(define-alias eqp         (x y)    (cl:eq x y))
(define-alias eqlp        (x y)    (cl:eql x y))
(define-alias equalp      (x y)    (cl:equal x y))
(define-alias equivalentp (x y)    (cl:equalp x y))
(define-alias everyp (predicate sequence &rest more-sequences)
  (apply #'cl:every predicate sequence more-sequences))

(define-alias notanyp (predicate sequence &rest more-sequences)
  (apply #'cl:notany predicate sequence more-sequences))

(define-alias noteveryp (predicate sequence &rest more-sequences)
  (apply #'cl:notevery predicate sequence more-sequences))

(define-alias char-equal-p (character &rest more-characters)
  (apply #'cl:char-equal character more-characters))

(define-alias char-not-equal-p (character &rest more-characters)
  (apply #'cl:char-not-equal character more-characters))

(define-alias string-equal-p (string1 string2 &rest keyword-arguments)
  (apply #'cl:string-equal string1 string2 keyword-arguments))

(define-alias string-not-equal-p (string1 string2 &rest keyword-arguments)
  (apply #'cl:string-not-equal string1 string2 keyword-arguments))

(defun normalize-hash-table-test (test)
  "Map a suffixed equality predicate to the standard hash table test it names,
leaving any other test designator untouched."
  (let ((designator (if (functionp test)
                        (multiple-value-bind (expression closure name)
                            (function-lambda-expression test)
                          (declare (ignore expression closure))
                          (or name test))
                        test)))
    (case designator
      ((eqp) 'cl:eq)
      ((eqlp) 'cl:eql)
      ((equalp) 'cl:equal)
      ((equivalentp) 'cl:equalp)
      (otherwise test))))

(defun make-hash-table (&rest keyword-arguments)
  "Create a hash table that accepts a suffixed equality predicate as its test."
  (let ((test (getf keyword-arguments :test 'eql)))
    (apply #'cl:make-hash-table
           :test (normalize-hash-table-test test)
           (alexandria:remove-from-plist keyword-arguments :test))))

;;; Standard accessor functions without redundant prefix

(define-alias universal-time       ()       (cl:get-universal-time))
(define-alias decoded-time         ()       (cl:get-decoded-time))
(define-alias internal-real-time   ()       (cl:get-internal-real-time))
(define-alias internal-run-time    ()       (cl:get-internal-run-time))
(define-alias output-stream-string (stream) (cl:get-output-stream-string stream))
(define-alias properties           (place indicator-list)
  (cl:get-properties place indicator-list))

(define-alias setf-expansion (place &optional environment)
  (cl:get-setf-expansion place environment))

(define-alias macro-character (character &optional (readtable *readtable*))
  (cl:get-macro-character character readtable))

(define-alias dispatch-macro-character
    (disp-char sub-char &optional (readtable *readtable*))
  (cl:get-dispatch-macro-character disp-char sub-char readtable))

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
