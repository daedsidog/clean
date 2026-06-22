(defpackage #:clean/mop-extensions
  (:use #:clean/aliases)
  (:shadow #:defclass #:defstruct)
  (:local-nicknames (#:mop #:closer-mop))
  (:export #:alias-parent-class-readers-for-child
           #:defclass
           #:defstruct
           #:invalid-class-parent-error))

(in-package #:clean/mop-extensions)

(define-condition invalid-class-parent-error (error)
  ((child :initarg :child :reader invalid-class-parent-error-child)
   (parents :initarg :parents :reader invalid-class-parent-error-parents))
  (:documentation
   "Error signaled when a class is not a parent of the specified child.")
  (:report (lambda (condition stream)
             (format stream "One element in ~A is not a parent class of ~A."
                     (invalid-class-parent-error-parents condition)
                     (invalid-class-parent-error-child condition)))))

(defun alias-parent-class-readers-for-child (child-class-symbol &rest parent-class-symbols)
  "Alias the readers of the parent classes for the child class.

If PARENT-CLASS-SYMBOLS are not provided, the direct superclasses of the child
class are used.  If a parent reader or the direct parent's alias is exported,
the child alias is also exported."
  (unless (every (lambda (x) (subtypep child-class-symbol x)) parent-class-symbols)
      (error 'invalid-class-parent-error
             :parents parent-class-symbols
             :child child-class-symbol))
  (let ((parent-classes (or (mapcar #'find-class parent-class-symbols)
                            (mop:class-direct-superclasses (find-class child-class-symbol))))
        (child-package (symbol-package child-class-symbol)))
    (loop :for parent-class :in parent-classes :do
      ;; Ensure the class is finalized before accessing its precedence list
      (unless (mop:class-finalized-p parent-class)
        (mop:finalize-inheritance parent-class))
      ;; Process direct slots of the parent and all its ancestors
      (loop :for ancestor-class :in (cons parent-class (mop:class-precedence-list parent-class)) :do
        (loop :for slot :in (mop:class-direct-slots ancestor-class) :do
          (loop :for reader :in (mop:slot-definition-readers slot) :do
            (let* ((prefix (symbol-name (class-name ancestor-class)))
                   (reader-name (symbol-name reader))
                   (reader-name-without-prefix
                     (if (and (>= (length reader-name) (length prefix))
                              (string= prefix reader-name :end2 (length prefix)))
                         (subseq reader-name (length prefix))
                         reader-name))
                   (new-reader-symbol (intern (format nil "~A~A"
                                                      (symbol-name child-class-symbol)
                                                      reader-name-without-prefix)
                                              child-package))
                   (reader-package (symbol-package reader)))
              (setf (symbol-function new-reader-symbol) (symbol-function reader))
              ;; Also alias the SETF function if it exists
              (when (fboundp `(setf ,reader))
                (setf (fdefinition `(setf ,new-reader-symbol))
                      (fdefinition `(setf ,reader))))
              ;; Export the new reader if the original reader or direct parent's
              ;; alias is exported
              (let ((should-export nil))
                ;; Check original reader
                (when reader-package
                  (multiple-value-bind (sym status)
                      (find-symbol (symbol-name reader) reader-package)
                    (declare (ignore sym))
                    (when (eqp status :external)
                      (setf should-export t))))
                ;; Check direct parent's alias
                (unless should-export
                  (let ((parent-name (format nil "~A~A"
                                             (symbol-name (class-name parent-class))
                                             reader-name-without-prefix))
                        (parent-pkg (symbol-package (class-name parent-class))))
                    (multiple-value-bind (sym status)
                        (find-symbol parent-name parent-pkg)
                      (declare (ignore sym))
                      (when (eqp status :external)
                        (setf should-export t)))))
                (when should-export
                  (export new-reader-symbol child-package))))))))))

(defmacro defclass (name direct-superclasses direct-slots &body options)
  "Define a class as with CL:DEFCLASS, with one additional class option:
:ALIAS-PARENT-READERS.

When :ALIAS-PARENT-READERS is true, reader functions inherited from each
superclass are aliased with NAME as the prefix.  For example, if superclass FOO
defines reader FOO-SLOT, child BAR receives BAR-SLOT bound to the same function.
SETF functions are aliased likewise.  If the original reader is exported from
its home package, the alias is exported from the child package.

All other options are passed through to CL:DEFCLASS unchanged."
  (let ((alias-parent-readers (second (find :alias-parent-readers options :key #'car)))
        (standard-options (remove :alias-parent-readers options :key #'car)))
    `(progn
       (cl:defclass ,name ,direct-superclasses ,direct-slots ,@standard-options)
       ,@(when alias-parent-readers
           `((alias-parent-class-readers-for-child ',name
                                             ,@(mapcar (lambda (class) `',class)
                                                       direct-superclasses)))))))

(defun welded-predicate-name (structure-name)
  "Return a structure's type predicate name, welded unless the name is hyphenated."
  (let ((name (symbol-name structure-name)))
    (intern (concatenate 'string name (if (find #\- name) "-P" "P"))
            (symbol-package structure-name))))

(defmacro defstruct (name-and-options &body slot-descriptions)
  "Define a structure, welding the predicate suffix unless the name is hyphenated."
  (multiple-value-bind (name options)
      (if (consp name-and-options)
          (values (car name-and-options) (cdr name-and-options))
          (values name-and-options nil))
    (let ((new-options
            (if (assoc :predicate options)
                options
                (cons (list :predicate (welded-predicate-name name)) options))))
      `(cl:defstruct (,name ,@new-options) ,@slot-descriptions))))
