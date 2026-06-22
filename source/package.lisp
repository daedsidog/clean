(uiop:define-package #:clean
  (:use #:cl)
  (:shadow #:atom #:null #:eq #:eql #:equal)
  (:shadowing-import-from #:clean/mop-extensions #:defclass #:defstruct)
  ;; Adopt CLEAN's curated predicate surface in place of the bare CL symbols the
  ;; blanket (:reexport #:cl) below would otherwise re-leak.
  (:shadowing-import-from #:clean/aliases
                          #:equalp
                          #:adjustable-array-p #:alpha-char-p #:alphanumericp
                          #:array-has-fill-pointer-p #:array-in-bounds-p #:arrayp
                          #:bit-vector-p #:both-case-p #:boundp #:characterp
                          #:compiled-function-p #:complexp #:consp #:constantp
                          #:digit-char-p #:endp #:evenp #:fboundp #:floatp
                          #:functionp #:graphic-char-p #:hash-table-p
                          #:input-stream-p #:integerp #:interactive-stream-p
                          #:keywordp #:listp #:logbitp #:lower-case-p #:minusp
                          #:numberp #:oddp #:open-stream-p #:output-stream-p
                          #:packagep #:pathname-match-p #:pathnamep #:plusp
                          #:random-state-p #:rationalp #:readtablep #:realp
                          #:simple-bit-vector-p #:simple-string-p
                          #:simple-vector-p #:slot-boundp #:slot-exists-p
                          #:special-operator-p #:standard-char-p #:streamp
                          #:stringp #:subsetp #:subtypep #:symbolp #:tailp
                          #:typep #:upper-case-p #:vectorp #:wild-pathname-p
                          #:y-or-n-p #:yes-or-no-p #:zerop
                          #:char-greaterp #:char-lessp #:char-not-greaterp
                          #:char-not-lessp #:string-greaterp #:string-lessp
                          #:string-not-greaterp #:string-not-lessp
                          #:read #:read-preserving-whitespace #:read-char
                          #:read-char-no-hang #:peek-char #:read-line
                          #:read-delimited-list #:read-from-string
                          #:pprint-fill #:pprint-linear #:pprint-tabular)
  (:reexport #:cl)
  (:use-reexport #:clean/aliases
                 #:clean/list-extensions
                 #:clean/package-extensions
                 #:clean/string-extensions
                 #:clean/mop-extensions))

(in-package #:clean)

;;; Drop the bare ANSI predicates that CLEAN replaces with suffixed forms.  The
;;; shadow above keeps them from CL's reexport, but the shadowing symbols are
;;; still re-exported under their bare names, so unexport them explicitly.

(unexport '(atom null eq eql equal) (find-package '#:clean))

#+sbcl
(progn
  (sb-ext:lock-package 'clean)
  (sb-ext:lock-package 'clean/aliases)
  (sb-ext:lock-package 'clean/list-extensions)
  (sb-ext:lock-package 'clean/package-extensions)
  (sb-ext:lock-package 'clean/string-extensions)
  (sb-ext:lock-package 'clean/mop-extensions))
