(uiop:define-package #:clean/aliases
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

(in-package #:clean/aliases)

(defmacro define-alias (name lambda-list &body body)
  "Define and export an inline wrapper forwarding to a Common Lisp function."
  `(progn
     (declaim (inline ,name))
     (defun ,name ,lambda-list ,@body)
     (export ',name)))

;;; Predicate aliases postfixed with 'p'

(define-alias atomp       (object) (cl:atom object))
(define-alias nullp       (object) (cl:null object))
(define-alias eqp         (x y)    (cl:eq x y))
(define-alias eqlp        (x y)    (cl:eql x y))
(define-alias equalp      (x y)    (cl:equal x y))
(define-alias equivalentp (x y)    (cl:equalp x y))

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
