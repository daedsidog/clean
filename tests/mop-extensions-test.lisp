;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defpackage #:ck-clle/tests/mop
  (:export #:run-tests)
  (:use #:cl #:fiveam #:ck-clle/mop-extensions))

(in-package #:ck-clle/tests/mop)

(defun run-tests ()
  (run! 'mop-test))

(def-suite* mop-test)

;; Test classes for single parent case
(defclass parent ()
  ((name :accessor parent-name :initarg :name)
   (age :accessor parent-age :initarg :age)))

(defclass child (parent)
  ((grade :accessor child-grade :initarg :grade)))

;; Test classes for dual parent case
(defclass father ()
  ((job :accessor father-job :initarg :job)))

(defclass mother ()
  ((hobby :accessor mother-hobby :initarg :hobby)))

(defclass kid (father mother)
  ((school :accessor kid-school :initarg :school)))

(test single-parent-reader-aliasing
  "Test that ALIAS-PARENT-READERS-FOR-CHILD works correctly with one parent class."
  ;; Create alias readers for child class based on single parent
  (alias-parent-readers-for-child 'child 'parent)
  ;; Create test instance
  (let ((instance (make-instance 'child
                                 :name "John"
                                 :age 25
                                 :grade "A")))
    ;; Test that original parent readers still work
    (is (string= "John" (parent-name instance)))
    (is (= 25 (parent-age instance)))
    ;; Test that aliased readers are created and work
    ;; Expected pattern: CHILD-<reader-name-without-class-prefix>
    (is (fboundp 'child-name))
    (is (string= "John" (funcall (symbol-function 'child-name) instance)))
    (is (fboundp 'child-age))
    (is (= 25 (funcall (symbol-function 'child-age) instance)))))

(test dual-parent-reader-aliasing
  "Test that ALIAS-PARENT-READERS-FOR-CHILD works correctly with two parent classes."
  ;; Create alias readers for child class based on multiple parents
  (alias-parent-readers-for-child 'kid 'father 'mother)
  ;; Create test instance
  (let ((instance (make-instance 'kid
                                 :job "Engineer"
                                 :hobby "Reading"
                                 :school "Elementary")))
    ;; Test that original parent readers still work
    (is (string= "Engineer" (father-job instance)))
    (is (string= "Reading" (mother-hobby instance)))
    ;; Test that aliased readers from first parent are created and work
    (is (fboundp 'kid-job))
    (is (string= "Engineer" (funcall (symbol-function 'kid-job) instance)))
    ;; Test that aliased readers from second parent are created and work
    (is (fboundp 'kid-hobby))
    (is (string= "Reading" (funcall (symbol-function 'kid-hobby) instance)))))

(test error-on-invalid-inheritance
  "Test that function throws error when class is not actually a parent."
  (defclass unrelated-class ()
    ((unrelated-slot :accessor unrelated-class-unrelated-slot)))
  ;; This should throw an error because UNRELATED-CLASS is not a parent of CHILD.
  (signals error
    (alias-parent-readers-for-child 'child 'unrelated-class)))

(test auto-export-aliased-readers
  "Test that aliased readers are automatically exported when parent readers are exported."
  ;; Create a test package with an exported parent class and readers
  (let ((test-package (make-package (gensym "TEST-PACKAGE-") :use '(#:cl))))
    (unwind-protect
         (progn
           ;; Define and export parent class and some readers
           (intern "EXPORTED-PARENT" test-package)
           (export (intern "EXPORTED-PARENT" test-package) test-package)
           (intern "EXPORTED-PARENT-SLOT1" test-package)
           (export (intern "EXPORTED-PARENT-SLOT1" test-package) test-package)
           (intern "EXPORTED-PARENT-SLOT2" test-package)
           (export (intern "EXPORTED-PARENT-SLOT2" test-package) test-package)
           ;; Define the parent class
           (let ((*package* test-package))
             (eval (read-from-string
                    "(defclass exported-parent ()
                       ((slot1 :initarg :slot1 :reader exported-parent-slot1)
                        (slot2 :initarg :slot2 :reader exported-parent-slot2)
                        (slot3 :initarg :slot3 :reader exported-parent-slot3)))")) ; Not exported
             ;; Use DEFCLASS* to create child
             (eval (read-from-string
                    "(ck-clle/mop-extensions:defclass* exported-child (exported-parent)
                       ((child-slot :initarg :child-slot :reader exported-child-child-slot))
                       (:alias-parent-readers t))")))
           ;; Test that the aliased readers for exported parent readers are exported
           (multiple-value-bind (sym1 status1)
               (find-symbol "EXPORTED-CHILD-SLOT1" test-package)
             (declare (ignore sym1))
             (is (eq status1 :external) "EXPORTED-CHILD-SLOT1 should be exported"))
           (multiple-value-bind (sym2 status2)
               (find-symbol "EXPORTED-CHILD-SLOT2" test-package)
             (declare (ignore sym2))
             (is (eq status2 :external) "EXPORTED-CHILD-SLOT2 should be exported"))
           ;; Test that the aliased reader for non-exported parent reader is NOT exported
           (multiple-value-bind (sym3 status3)
               (find-symbol "EXPORTED-CHILD-SLOT3" test-package)
             (declare (ignore sym3))
             (is (not (eq status3 :external)) "EXPORTED-CHILD-SLOT3 should NOT be exported"))
           ;; Test deeper inheritance - export child reader for grandchild test
           (export (intern "EXPORTED-CHILD-CHILD-SLOT" test-package) test-package)
           (let ((*package* test-package))
             ;; Create grandchild using DEFCLASS*
             (eval (read-from-string
                    "(ck-clle/mop-extensions:defclass* exported-grandchild (exported-child)
                       ((grandchild-slot :initarg :grandchild-slot
                                         :reader exported-grandchild-grandchild-slot))
                       (:alias-parent-readers t))")))
           ;; Test that grandchild inherits export status from both parent and grandparent
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GRANDCHILD-SLOT1" test-package)
             (declare (ignore sym))
             (is (eq status :external)
                 "EXPORTED-GRANDCHILD-SLOT1 should be exported (from grandparent)"))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GRANDCHILD-SLOT2" test-package)
             (declare (ignore sym))
             (is (eq status :external)
                 "EXPORTED-GRANDCHILD-SLOT2 should be exported (from grandparent)"))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GRANDCHILD-CHILD-SLOT" test-package)
             (declare (ignore sym))
             (is (eq status :external)
                 "EXPORTED-GRANDCHILD-CHILD-SLOT should be exported (from parent)"))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GRANDCHILD-SLOT3" test-package)
             (declare (ignore sym))
             (is (not (eq status :external)) "EXPORTED-GRANDCHILD-SLOT3 should NOT be exported"))
           ;; Test even deeper (great-grandchild)
           (let ((*package* test-package))
             (eval (read-from-string
                    "(ck-clle/mop-extensions:defclass* exported-great-grandchild
                         (exported-grandchild)
                       ((gg-slot :initarg :gg-slot
                                 :reader exported-great-grandchild-gg-slot))
                       (:alias-parent-readers t))")))
           ;; Verify that great-grandchild still inherits proper export status
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GREAT-GRANDCHILD-SLOT1" test-package)
             (declare (ignore sym))
             (is (eq status :external)
                 "EXPORTED-GREAT-GRANDCHILD-SLOT1 should be exported (3 levels up)"))
           (multiple-value-bind (sym status)
               (find-symbol "EXPORTED-GREAT-GRANDCHILD-CHILD-SLOT" test-package)
             (declare (ignore sym))
             (is (eq status :external)
                 "EXPORTED-GREAT-GRANDCHILD-CHILD-SLOT should be exported (2 levels up)")))
      ;; Cleanup
      (delete-package test-package))))
