(defpackage #:clean/tests/mop-extensions-test
  (:export #:run-tests)
  (:use #:clean #:fiveam))

(in-package #:clean/tests/mop-extensions-test)

(defun run-tests ()
  "Run the MOP extension test suite."
  (run! 'mop-test))

(def-suite* mop-test)

;;; Test fixtures

(defclass parent ()
  ((name :accessor parent-name :initarg :name)
   (age :accessor parent-age :initarg :age)))

(defclass child (parent)
  ((grade :accessor child-grade :initarg :grade)))

(defclass father ()
  ((job :accessor father-job :initarg :job)))

(defclass mother ()
  ((hobby :accessor mother-hobby :initarg :hobby)))

(defclass kid (father mother)
  ((school :accessor kid-school :initarg :school)))

;;; Tests

(test single-parent-reader-aliasing
  "Verify that reader aliases are created for a single parent class."
  (alias-parent-class-readers-for-child 'child 'parent)
  (let ((instance (make-instance 'child :name "John" :age 25 :grade "A")))
    (is (string= "John" (parent-name instance)))
    (is (= 25 (parent-age instance)))
    (is (fboundp 'child-name))
    (is (string= "John" (funcall (symbol-function 'child-name) instance)))
    (is (fboundp 'child-age))
    (is (= 25 (funcall (symbol-function 'child-age) instance)))))

(test dual-parent-reader-aliasing
  "Verify that reader aliases are created for multiple parent classes."
  (alias-parent-class-readers-for-child 'kid 'father 'mother)
  (let ((instance (make-instance 'kid :job "Engineer" :hobby "Reading" :school "Elementary")))
    (is (string= "Engineer" (father-job instance)))
    (is (string= "Reading" (mother-hobby instance)))
    (is (fboundp 'kid-job))
    (is (string= "Engineer" (funcall (symbol-function 'kid-job) instance)))
    (is (fboundp 'kid-hobby))
    (is (string= "Reading" (funcall (symbol-function 'kid-hobby) instance)))))

(test error-on-invalid-inheritance
  "Verify that ALIAS-PARENT-CLASS-READERS-FOR-CHILD signals an error for non-parent classes."
  (defclass unrelated-class ()
    ((unrelated-slot :accessor unrelated-class-unrelated-slot)))
  (signals error
    (alias-parent-class-readers-for-child 'child 'unrelated-class)))

(test auto-export-aliased-readers
  "Verify that aliased readers inherit the export status of the original readers."
  (let ((test-package (make-package (gensym "TEST-PACKAGE-") :use '(#:cl))))
    (unwind-protect
         (progn
           (intern "EXPORTED-PARENT" test-package)
           (export (intern "EXPORTED-PARENT" test-package) test-package)
           (intern "EXPORTED-PARENT-SLOT1" test-package)
           (export (intern "EXPORTED-PARENT-SLOT1" test-package) test-package)
           (intern "EXPORTED-PARENT-SLOT2" test-package)
           (export (intern "EXPORTED-PARENT-SLOT2" test-package) test-package)
           ;; Define parent class with MOP instead of EVAL
           (closer-mop:ensure-class
            (intern "EXPORTED-PARENT" test-package)
            :direct-superclasses '(standard-object)
            :direct-slots `((:name ,(intern "SLOT1" test-package)
                             :initargs (,(intern "SLOT1" :keyword))
                             :readers (,(intern "EXPORTED-PARENT-SLOT1" test-package)))
                            (:name ,(intern "SLOT2" test-package)
                             :initargs (,(intern "SLOT2" :keyword))
                             :readers (,(intern "EXPORTED-PARENT-SLOT2" test-package)))
                            (:name ,(intern "SLOT3" test-package)
                             :initargs (,(intern "SLOT3" :keyword))
                             :readers (,(intern "EXPORTED-PARENT-SLOT3" test-package)))))
           ;; Define child class with :ALIAS-PARENT-READERS
           (closer-mop:ensure-class
            (intern "EXPORTED-CHILD" test-package)
            :direct-superclasses (list (find-class (intern "EXPORTED-PARENT" test-package)))
            :direct-slots `((:name ,(intern "CHILD-SLOT" test-package)
                             :initargs (,(intern "CHILD-SLOT" :keyword))
                             :readers (,(intern "EXPORTED-CHILD-CHILD-SLOT" test-package)))))
           (alias-parent-class-readers-for-child
            (intern "EXPORTED-CHILD" test-package)
            (intern "EXPORTED-PARENT" test-package))
           ;; Exported parent readers should produce exported child aliases
           (multiple-value-bind (sym1 status1)
               (find-symbol "EXPORTED-CHILD-SLOT1" test-package)
             (declare (ignore sym1))
             (is (eqp status1 :external) "EXPORTED-CHILD-SLOT1 should be exported"))
           (multiple-value-bind (sym2 status2)
               (find-symbol "EXPORTED-CHILD-SLOT2" test-package)
             (declare (ignore sym2))
             (is (eqp status2 :external) "EXPORTED-CHILD-SLOT2 should be exported"))
           ;; Non-exported parent reader should NOT produce exported child alias
           (multiple-value-bind (sym3 status3)
               (find-symbol "EXPORTED-CHILD-SLOT3" test-package)
             (declare (ignore sym3))
             (is (not (eqp status3 :external)) "EXPORTED-CHILD-SLOT3 should NOT be exported"))
           ;; Test deeper inheritance
           (export (intern "EXPORTED-CHILD-CHILD-SLOT" test-package) test-package)
           (closer-mop:ensure-class
            (intern "EXPORTED-GRANDCHILD" test-package)
            :direct-superclasses (list (find-class (intern "EXPORTED-CHILD" test-package)))
            :direct-slots `((:name ,(intern "GRANDCHILD-SLOT" test-package)
                             :initargs (,(intern "GRANDCHILD-SLOT" :keyword))
                             :readers (,(intern "EXPORTED-GRANDCHILD-GRANDCHILD-SLOT"
                                                test-package)))))
           (alias-parent-class-readers-for-child
            (intern "EXPORTED-GRANDCHILD" test-package)
            (intern "EXPORTED-CHILD" test-package))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GRANDCHILD-SLOT1" test-package)
             (declare (ignore sym))
             (is (eqp status :external)
                 "EXPORTED-GRANDCHILD-SLOT1 should be exported (from grandparent)"))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GRANDCHILD-SLOT2" test-package)
             (declare (ignore sym))
             (is (eqp status :external)
                 "EXPORTED-GRANDCHILD-SLOT2 should be exported (from grandparent)"))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GRANDCHILD-CHILD-SLOT" test-package)
             (declare (ignore sym))
             (is (eqp status :external)
                 "EXPORTED-GRANDCHILD-CHILD-SLOT should be exported (from parent)"))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GRANDCHILD-SLOT3" test-package)
             (declare (ignore sym))
             (is (not (eqp status :external))
                 "EXPORTED-GRANDCHILD-SLOT3 should NOT be exported"))
           ;; Test great-grandchild
           (closer-mop:ensure-class
            (intern "EXPORTED-GREAT-GRANDCHILD" test-package)
            :direct-superclasses (list (find-class (intern "EXPORTED-GRANDCHILD" test-package)))
            :direct-slots `((:name ,(intern "GG-SLOT" test-package)
                             :initargs (,(intern "GG-SLOT" :keyword))
                             :readers (,(intern "EXPORTED-GREAT-GRANDCHILD-GG-SLOT"
                                                test-package)))))
           (alias-parent-class-readers-for-child
            (intern "EXPORTED-GREAT-GRANDCHILD" test-package)
            (intern "EXPORTED-GRANDCHILD" test-package))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GREAT-GRANDCHILD-SLOT1" test-package)
             (declare (ignore sym))
             (is (eqp status :external)
                 "EXPORTED-GREAT-GRANDCHILD-SLOT1 should be exported (3 levels up)"))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GREAT-GRANDCHILD-CHILD-SLOT" test-package)
             (declare (ignore sym))
             (is (eqp status :external)
                 "EXPORTED-GREAT-GRANDCHILD-CHILD-SLOT should be exported (2 levels up)")))
      (delete-package test-package))))
