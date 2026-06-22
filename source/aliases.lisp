(uiop:define-package #:clean/aliases
  (:use #:cl)
  (:shadow #:equalp
           ;; Bare predicates dropped from CLEAN's surface, replaced by suffixed forms
           #:atom #:null #:eq #:eql #:equal
           ;; Compliant CL predicates re-defined as inline wrappers
           #:adjustable-array-p #:alpha-char-p #:alphanumericp
           #:array-has-fill-pointer-p #:array-in-bounds-p #:arrayp
           #:bit-vector-p #:both-case-p #:boundp #:characterp
           #:compiled-function-p #:complexp #:consp #:constantp
           #:digit-char-p #:endp #:evenp #:fboundp #:floatp #:functionp
           #:graphic-char-p #:hash-table-p #:input-stream-p #:integerp
           #:interactive-stream-p #:keywordp #:listp #:logbitp
           #:lower-case-p #:minusp #:numberp #:oddp #:open-stream-p
           #:output-stream-p #:packagep #:pathname-match-p #:pathnamep
           #:plusp #:random-state-p #:rationalp #:readtablep #:realp
           #:simple-bit-vector-p #:simple-string-p #:simple-vector-p
           #:slot-boundp #:slot-exists-p #:special-operator-p
           #:standard-char-p #:streamp #:stringp #:subsetp #:subtypep
           #:symbolp #:tailp #:typep #:upper-case-p #:vectorp
           #:wild-pathname-p #:y-or-n-p #:yes-or-no-p #:zerop
           ;; Compliant CL comparison predicates re-defined as inline wrappers
           #:char-greaterp #:char-lessp #:char-not-greaterp #:char-not-lessp
           #:string-greaterp #:string-lessp #:string-not-greaterp
           #:string-not-lessp
           ;; Read and pretty-print functions re-wrapped for DESCRIBE compliance
           #:read #:read-preserving-whitespace #:read-char
           #:read-char-no-hang #:peek-char #:read-line #:read-delimited-list
           #:read-from-string #:pprint-fill #:pprint-linear #:pprint-tabular)
  (:import-from #:alexandria
                #:with-gensyms #:when-let #:if-let #:iota)
  (:export #:atomp                    ; Equality and identity predicate aliases
           #:nullp                    ;
           #:eqp                      ;
           #:eqlp                     ;
           #:equalp                   ;
           #:equivalentp              ;
           #:everyp                   ; Sequence-quantifier predicate aliases
           #:notanyp                  ;
           #:noteveryp                ;
           #:string-equalp            ; Comparison predicate aliases
           #:string-not-equalp        ;
           #:char-equalp              ;
           #:char-not-equalp          ;
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

;;; Drop the bare ANSI predicates that CLEAN replaces with suffixed forms.  The
;;; (:reexport #:cl) above re-exports the shadowing symbols under their bare
;;; names, so an explicit unexport is required to remove them from the surface.

(unexport '(atom null eq eql equal) (find-package '#:clean/aliases))

(defmacro define-alias (name lambda-list &body body)
  "Define and export NAME as a declaimed-inline wrapper forwarding to its CL
original.  An inline wrapper preserves the original's open-coding transforms and
flow-typing and presents the compliant lambda list under DESCRIBE, neither of
which a bare FDEFINITION copy retains."
  `(progn
     (declaim (inline ,name))
     (defun ,name ,lambda-list ,@body)
     (export ',name)))

;;; Equality and identity predicates postfixed with 'p'

(define-alias atomp (object) (cl:atom object))
(define-alias nullp (object) (cl:null object))
(define-alias eqp (x y) (cl:eq x y))
(define-alias eqlp (x y) (cl:eql x y))
(define-alias equalp (x y) (cl:equal x y))
(define-alias equivalentp (x y) (cl:equalp x y))

;;; Sequence-quantifier predicates postfixed with 'p'

(define-alias everyp (predicate sequence &rest more-sequences)
  (apply #'cl:every predicate sequence more-sequences))
(define-alias notanyp (predicate sequence &rest more-sequences)
  (apply #'cl:notany predicate sequence more-sequences))
(define-alias noteveryp (predicate sequence &rest more-sequences)
  (apply #'cl:notevery predicate sequence more-sequences))

;;; Compliant CL predicates routed through inline wrappers in place of a blanket
;;; reexport, so CLEAN owns and exports them under its own convention.

(define-alias adjustable-array-p (array) (cl:adjustable-array-p array))
(define-alias alpha-char-p (character) (cl:alpha-char-p character))
(define-alias alphanumericp (character) (cl:alphanumericp character))
(define-alias array-has-fill-pointer-p (array) (cl:array-has-fill-pointer-p array))
(define-alias array-in-bounds-p (array &rest subscripts)
  (apply #'cl:array-in-bounds-p array subscripts))
(define-alias arrayp (object) (cl:arrayp object))
(define-alias bit-vector-p (object) (cl:bit-vector-p object))
(define-alias both-case-p (character) (cl:both-case-p character))
(define-alias boundp (symbol) (cl:boundp symbol))
(define-alias characterp (object) (cl:characterp object))
(define-alias compiled-function-p (object) (cl:compiled-function-p object))
(define-alias complexp (object) (cl:complexp object))
(define-alias consp (object) (cl:consp object))
(define-alias constantp (form &optional (environment nil environment-supplied))
  (if environment-supplied (cl:constantp form environment) (cl:constantp form)))
(define-alias digit-char-p (character &optional (radix nil radix-supplied))
  (if radix-supplied (cl:digit-char-p character radix) (cl:digit-char-p character)))
(define-alias endp (list) (cl:endp list))
(define-alias evenp (integer) (cl:evenp integer))
(define-alias fboundp (name) (cl:fboundp name))
(define-alias floatp (object) (cl:floatp object))
(define-alias functionp (object) (cl:functionp object))
(define-alias graphic-char-p (character) (cl:graphic-char-p character))
(define-alias hash-table-p (object) (cl:hash-table-p object))
(define-alias input-stream-p (stream) (cl:input-stream-p stream))
(define-alias integerp (object) (cl:integerp object))
(define-alias interactive-stream-p (stream) (cl:interactive-stream-p stream))
(define-alias keywordp (object) (cl:keywordp object))
(define-alias listp (object) (cl:listp object))
(define-alias logbitp (index integer) (cl:logbitp index integer))
(define-alias lower-case-p (character) (cl:lower-case-p character))
(define-alias minusp (number) (cl:minusp number))
(define-alias numberp (object) (cl:numberp object))
(define-alias oddp (integer) (cl:oddp integer))
(define-alias open-stream-p (stream) (cl:open-stream-p stream))
(define-alias output-stream-p (stream) (cl:output-stream-p stream))
(define-alias packagep (object) (cl:packagep object))
(define-alias pathname-match-p (pathname wildname) (cl:pathname-match-p pathname wildname))
(define-alias pathnamep (object) (cl:pathnamep object))
(define-alias plusp (number) (cl:plusp number))
(define-alias random-state-p (object) (cl:random-state-p object))
(define-alias rationalp (object) (cl:rationalp object))
(define-alias readtablep (object) (cl:readtablep object))
(define-alias realp (object) (cl:realp object))
(define-alias simple-bit-vector-p (object) (cl:simple-bit-vector-p object))
(define-alias simple-string-p (object) (cl:simple-string-p object))
(define-alias simple-vector-p (object) (cl:simple-vector-p object))
(define-alias slot-boundp (object slot-name) (cl:slot-boundp object slot-name))
(define-alias slot-exists-p (object slot-name) (cl:slot-exists-p object slot-name))
(define-alias special-operator-p (symbol) (cl:special-operator-p symbol))
(define-alias standard-char-p (character) (cl:standard-char-p character))
(define-alias streamp (object) (cl:streamp object))
(define-alias stringp (object) (cl:stringp object))
(define-alias subsetp (list1 list2 &rest keyword-arguments)
  (apply #'cl:subsetp list1 list2 keyword-arguments))
(define-alias subtypep (type1 type2 &optional (environment nil environment-supplied))
  (if environment-supplied (cl:subtypep type1 type2 environment) (cl:subtypep type1 type2)))
(define-alias symbolp (object) (cl:symbolp object))
(define-alias tailp (object list) (cl:tailp object list))
(define-alias typep (object type &optional (environment nil environment-supplied))
  (if environment-supplied (cl:typep object type environment) (cl:typep object type)))
(define-alias upper-case-p (character) (cl:upper-case-p character))
(define-alias vectorp (object) (cl:vectorp object))
(define-alias wild-pathname-p (pathname &optional (field-key nil field-key-supplied))
  (if field-key-supplied (cl:wild-pathname-p pathname field-key) (cl:wild-pathname-p pathname)))
(define-alias y-or-n-p (&optional format-string &rest arguments)
  (apply #'cl:y-or-n-p format-string arguments))
(define-alias yes-or-no-p (&optional format-string &rest arguments)
  (apply #'cl:yes-or-no-p format-string arguments))
(define-alias zerop (number) (cl:zerop number))

;;; Word-named comparison predicates.  This closed family welds the final 'p'
;;; regardless of an index-versus-boolean return.  The already-suffixed members
;;; are kept under their CL names; the four bare members gain the welded 'p'.

(define-alias char-greaterp (character &rest more-characters)
  (apply #'cl:char-greaterp character more-characters))
(define-alias char-lessp (character &rest more-characters)
  (apply #'cl:char-lessp character more-characters))
(define-alias char-not-greaterp (character &rest more-characters)
  (apply #'cl:char-not-greaterp character more-characters))
(define-alias char-not-lessp (character &rest more-characters)
  (apply #'cl:char-not-lessp character more-characters))
(define-alias char-equalp (character &rest more-characters)
  (apply #'cl:char-equal character more-characters))
(define-alias char-not-equalp (character &rest more-characters)
  (apply #'cl:char-not-equal character more-characters))
(define-alias string-greaterp (string1 string2 &rest keyword-arguments)
  (apply #'cl:string-greaterp string1 string2 keyword-arguments))
(define-alias string-lessp (string1 string2 &rest keyword-arguments)
  (apply #'cl:string-lessp string1 string2 keyword-arguments))
(define-alias string-not-greaterp (string1 string2 &rest keyword-arguments)
  (apply #'cl:string-not-greaterp string1 string2 keyword-arguments))
(define-alias string-not-lessp (string1 string2 &rest keyword-arguments)
  (apply #'cl:string-not-lessp string1 string2 keyword-arguments))
(define-alias string-equalp (string1 string2 &rest keyword-arguments)
  (apply #'cl:string-equal string1 string2 keyword-arguments))
(define-alias string-not-equalp (string1 string2 &rest keyword-arguments)
  (apply #'cl:string-not-equal string1 string2 keyword-arguments))

;;; Read family re-wrapped for DESCRIBE compliance:  the EOF-ERROR-P and
;;; RECURSIVE-P parameters are stripped to plain words.  Conditional forwarding
;;; with supplied-p preserves each original's defaults.

(define-alias read (&optional (stream *standard-input* stream-supplied)
                              (eof-error t eof-error-supplied)
                              (eof-value nil eof-value-supplied)
                              (recursive nil recursive-supplied))
  (cond (recursive-supplied (cl:read stream eof-error eof-value recursive))
        (eof-value-supplied (cl:read stream eof-error eof-value))
        (eof-error-supplied (cl:read stream eof-error))
        (stream-supplied (cl:read stream))
        (t (cl:read))))
(define-alias read-preserving-whitespace
    (&optional (stream *standard-input* stream-supplied)
               (eof-error t eof-error-supplied)
               (eof-value nil eof-value-supplied)
               (recursive nil recursive-supplied))
  (cond (recursive-supplied
         (cl:read-preserving-whitespace stream eof-error eof-value recursive))
        (eof-value-supplied
         (cl:read-preserving-whitespace stream eof-error eof-value))
        (eof-error-supplied (cl:read-preserving-whitespace stream eof-error))
        (stream-supplied (cl:read-preserving-whitespace stream))
        (t (cl:read-preserving-whitespace))))
(define-alias read-char (&optional (stream *standard-input* stream-supplied)
                                   (eof-error t eof-error-supplied)
                                   (eof-value nil eof-value-supplied)
                                   (recursive nil recursive-supplied))
  (cond (recursive-supplied (cl:read-char stream eof-error eof-value recursive))
        (eof-value-supplied (cl:read-char stream eof-error eof-value))
        (eof-error-supplied (cl:read-char stream eof-error))
        (stream-supplied (cl:read-char stream))
        (t (cl:read-char))))
(define-alias read-char-no-hang
    (&optional (stream *standard-input* stream-supplied)
               (eof-error t eof-error-supplied)
               (eof-value nil eof-value-supplied)
               (recursive nil recursive-supplied))
  (cond (recursive-supplied
         (cl:read-char-no-hang stream eof-error eof-value recursive))
        (eof-value-supplied (cl:read-char-no-hang stream eof-error eof-value))
        (eof-error-supplied (cl:read-char-no-hang stream eof-error))
        (stream-supplied (cl:read-char-no-hang stream))
        (t (cl:read-char-no-hang))))
(define-alias peek-char (&optional (peek-type nil peek-type-supplied)
                                   (stream *standard-input* stream-supplied)
                                   (eof-error t eof-error-supplied)
                                   (eof-value nil eof-value-supplied)
                                   (recursive nil recursive-supplied))
  (cond (recursive-supplied
         (cl:peek-char peek-type stream eof-error eof-value recursive))
        (eof-value-supplied (cl:peek-char peek-type stream eof-error eof-value))
        (eof-error-supplied (cl:peek-char peek-type stream eof-error))
        (stream-supplied (cl:peek-char peek-type stream))
        (peek-type-supplied (cl:peek-char peek-type))
        (t (cl:peek-char))))
(define-alias read-line (&optional (stream *standard-input* stream-supplied)
                                   (eof-error t eof-error-supplied)
                                   (eof-value nil eof-value-supplied)
                                   (recursive nil recursive-supplied))
  (cond (recursive-supplied (cl:read-line stream eof-error eof-value recursive))
        (eof-value-supplied (cl:read-line stream eof-error eof-value))
        (eof-error-supplied (cl:read-line stream eof-error))
        (stream-supplied (cl:read-line stream))
        (t (cl:read-line))))
(define-alias read-delimited-list
    (end-character &optional (stream *standard-input* stream-supplied)
                             (recursive nil recursive-supplied))
  (cond (recursive-supplied (cl:read-delimited-list end-character stream recursive))
        (stream-supplied (cl:read-delimited-list end-character stream))
        (t (cl:read-delimited-list end-character))))
(define-alias read-from-string
    (string &optional (eof-error t eof-error-supplied)
                      (eof-value nil eof-value-supplied)
            &key (start 0) end preserve-whitespace)
  (cond (eof-value-supplied
         (cl:read-from-string string eof-error eof-value
                              :start start :end end
                              :preserve-whitespace preserve-whitespace))
        (eof-error-supplied
         (cl:read-from-string string eof-error nil
                              :start start :end end
                              :preserve-whitespace preserve-whitespace))
        (t (cl:read-from-string string t nil
                                :start start :end end
                                :preserve-whitespace preserve-whitespace))))

;;; Pretty-print dispatchers re-wrapped for DESCRIBE compliance:  the COLON-P
;;; and AT-SIGN-P parameters are stripped to plain words.

(define-alias pprint-fill (stream object &optional (colon t colon-supplied)
                                         (at-sign nil at-sign-supplied))
  (cond (at-sign-supplied (cl:pprint-fill stream object colon at-sign))
        (colon-supplied (cl:pprint-fill stream object colon))
        (t (cl:pprint-fill stream object))))
(define-alias pprint-linear (stream object &optional (colon t colon-supplied)
                                           (at-sign nil at-sign-supplied))
  (cond (at-sign-supplied (cl:pprint-linear stream object colon at-sign))
        (colon-supplied (cl:pprint-linear stream object colon))
        (t (cl:pprint-linear stream object))))
(define-alias pprint-tabular (stream object &optional (colon t colon-supplied)
                                            (at-sign nil at-sign-supplied)
                                            (tabsize nil tabsize-supplied))
  (cond (tabsize-supplied (cl:pprint-tabular stream object colon at-sign tabsize))
        (at-sign-supplied (cl:pprint-tabular stream object colon at-sign))
        (colon-supplied (cl:pprint-tabular stream object colon))
        (t (cl:pprint-tabular stream object))))

;;; Standard accessor functions without redundant prefix

(define-alias universal-time () (cl:get-universal-time))
(define-alias decoded-time () (cl:get-decoded-time))
(define-alias internal-real-time () (cl:get-internal-real-time))
(define-alias internal-run-time () (cl:get-internal-run-time))
(define-alias output-stream-string (stream) (cl:get-output-stream-string stream))
(define-alias properties (place indicator-list)
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
