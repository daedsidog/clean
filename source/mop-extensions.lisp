(defpackage #:clean/mop-extensions
  (:use #:clean/preamble)
  (:shadow #:defclass)
  (:local-nicknames (#:mop #:closer-mop))
  (:export #:alias-parent-class-readers-for-child
           #:defclass))

(in-package #:clean/mop-extensions)

(defun alias-parent-class-readers-for-child (child-class-symbol &rest parent-class-symbols)
  "Alias the readers of the parent classes for the child class.

If PARENT-CLASS-SYMBOLS are not provided, the direct superclasses of the child class are used.
If a parent reader or the direct parent's alias is exported, the child alias is also exported."
  (unless (every (lambda (x) (subtypep child-class-symbol x)) parent-class-symbols)
      (error "One element in ~A is not a parent class of ~A."
             parent-class-symbols child-class-symbol))
  (let ((parent-classes (or (mapcar #'find-class parent-class-symbols)
                            (mop:class-direct-superclasses (find-class child-class-symbol))))
        (child-package (symbol-package child-class-symbol)))
    (loop :for parent-class :in parent-classes :do
      ;; Ensure the class is finalized before accessing its precedence list
      (unless (mop:class-finalized-p parent-class)
        (mop:finalize-inheritance parent-class))
      ;; Process direct slots of the parent and all its ancestors
      (loop :for ancestor-class :in (cons parent-class
                                           (mop:class-precedence-list parent-class)) :do
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
              ;; Export the new reader if the original reader or direct parent's alias is exported
              (let ((should-export nil))
                ;; Check original reader
                (when reader-package
                  (multiple-value-bind (sym status)
                      (find-symbol (symbol-name reader) reader-package)
                    (declare (ignore sym))
                    (when (eq status :external)
                      (setf should-export t))))
                ;; Check direct parent's alias
                (unless should-export
                  (let* ((parent-name (format nil "~A~A"
                                              (symbol-name (class-name parent-class))
                                              reader-name-without-prefix))
                         (parent-pkg (symbol-package (class-name parent-class))))
                    (multiple-value-bind (sym status)
                        (find-symbol parent-name parent-pkg)
                      (declare (ignore sym))
                      (when (eq status :external)
                        (setf should-export t)))))
                (when should-export
                  (export new-reader-symbol child-package))))))))))

(defmacro defclass (name direct-superclasses direct-slots &body options)
  "Define a class with extended DEFCLASS options:

ALIAS-PARENT-READERS ::= generalized-boolean"
  ;; When true, calls ALIAS-PARENT-CLASS-READERS-FOR-CHILD on the class.
  ;;
  ;; Example:
  ;;
  ;;   (cl:defclass drawable ()
  ;;     ((left :initarg :left :accessor drawable-left)))
  ;;
  ;;   (defclass polygon (drawable)
  ;;     ((points :initarg :points :reader polygon-points))
  ;;     (:alias-parent-readers t))
  ;;
  ;; This creates POLYGON and also defines POLYGON-LEFT as an alias for DRAWABLE-LEFT:
  ;;
  ;;   (let ((p (make-instance 'polygon :left 10 :points '())))
  ;;     (polygon-left p))            ; => 10
  ;;     (drawable-left p))           ; => 10
  ;;     (setf (polygon-left p) 20)   ; Works if slot has writer
  ;;     (setf (drawable-left p) 20)) ; Works
  (let* ((alias-parent-readers (second (find :alias-parent-readers options :key #'car)))
         (standard-options (remove :alias-parent-readers options :key #'car)))
    `(progn
       (cl:defclass ,name ,direct-superclasses ,direct-slots ,@standard-options)
       ,@(when alias-parent-readers
           `((alias-parent-class-readers-for-child ',name
                                             ,@(mapcar (lambda (class) `',class)
                                                       direct-superclasses)))))))
