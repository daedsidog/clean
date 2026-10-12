(uiop:define-package #:clean/aliases
  (:use #:cl)
  (:shadow #:eq #:equal #:null #:atom #:equalp #:make-hash-table)
  (:import-from #:alexandria
                #:with-gensyms #:when-let #:if-let #:iota #:make-keyword)
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
           #:string-equalp            ;
           #:string-not-equalp        ;
           #:char-equalp              ;
           #:char-not-equalp          ;
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
           #:legacy-symbol-aliases    ; Alias listing
           #:with-gensyms             ; Alexandria imports
           #:when-let                 ;
           #:if-let                   ;
           #:iota                     ;
           #:make-keyword)            ;
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

(defvar *legacy-symbol-aliases* '()
  "Aliases defined so far, each paired with the Common Lisp symbol it replaces, the
latest first.")

(defmacro define-alias (name legacy-name lambda-list)
  "Define and export an inline wrapper forwarding to the Common Lisp function
LEGACY-NAME."
  (multiple-value-bind (required optional rest) (alexandria:parse-ordinary-lambda-list lambda-list)
    (let ((arguments (append required (mapcar #'first optional))))
      `(progn
         (declaim (inline ,name))
         (defun ,name ,lambda-list
           ,(if rest
                `(apply #',legacy-name ,@arguments ,rest)
                `(,legacy-name ,@arguments)))
         (export ',name)
         (pushnew (cons ',name ',legacy-name) *legacy-symbol-aliases* :key #'car)))))

(defun legacy-symbol-aliases ()
  "Return an alist pairing each alias CLEAN defines with the Common Lisp symbol it
replaces."
  (reverse (copy-alist *legacy-symbol-aliases*)))

;;; Predicate aliases postfixed with 'p'

(deftype null () 'cl:null)
(deftype atom () 'cl:atom)

(define-alias atomp             cl:atom             (object))
(define-alias nullp             cl:null             (object))
(define-alias eqp               cl:eq               (x y))
(define-alias eqlp              cl:eql              (x y))
(define-alias equalp            cl:equal            (x y))
(define-alias equivalentp       cl:equalp           (x y))
(define-alias everyp            cl:every            (predicate sequence &rest more-sequences))
(define-alias notanyp           cl:notany           (predicate sequence &rest more-sequences))
(define-alias noteveryp         cl:notevery         (predicate sequence &rest more-sequences))
(define-alias char-equalp       cl:char-equal       (character &rest more-characters))
(define-alias char-not-equalp   cl:char-not-equal   (character &rest more-characters))
(define-alias string-equalp     cl:string-equal     (string1 string2 &rest keyword-arguments))
(define-alias string-not-equalp cl:string-not-equal (string1 string2 &rest keyword-arguments))

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

(define-alias universal-time       cl:get-universal-time       ())
(define-alias decoded-time         cl:get-decoded-time         ())
(define-alias internal-real-time   cl:get-internal-real-time   ())
(define-alias internal-run-time    cl:get-internal-run-time    ())
(define-alias output-stream-string cl:get-output-stream-string (stream))
(define-alias properties           cl:get-properties           (place indicator-list))
(define-alias setf-expansion       cl:get-setf-expansion       (place &optional environment))
(define-alias macro-character      cl:get-macro-character
    (character &optional (readtable *readtable*)))

(define-alias dispatch-macro-character cl:get-dispatch-macro-character
    (disp-char sub-char &optional (readtable *readtable*)))

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
