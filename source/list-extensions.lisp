;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defpackage #:clean/list-extensions
  (:use #:cl)
  (:import-from #:alexandria #:flatten)
  (:export #:flatten #:duplicates #:unique #:cars #:recursive-mapl))

(in-package #:clean/list-extensions)

(defun duplicates (data-list &optional &key (test #'eqp))
  "Return a list of duplicate elements in DATA-LIST."
  (check-type data-list list)
  (let ((hash (make-hash-table :test test)))
    (loop :for x :in data-list
          :when (= (incf (gethash x hash 0)) 2)
          :collect x :into dupes
          :finally (return dupes))))

(defun unique (data-list &optional &key (test #'eqp))
  "Return a list of unique elements in DATA-LIST."
  (let ((hash (make-hash-table :test test)))
    (loop :for x :in data-list
          :when (= (incf (gethash x hash 0)) 1)
          :collect x :into uniques
          :finally (return uniques))))

(defun cars (list)
  "Return the CAR of each nonempty list in LIST."
  (let ((is-first-iteration t))
    (let ((cars (loop :for item :in list
                      :if (listp item)
                        :collect (nreverse (cars item)) :into cars
                      :else
                        :when is-first-iteration
                          :collect item :into cars
                          :and :do (setf is-first-iteration nil)
                      :finally (return cars))))
      (flatten cars))))

(defun recursive-mapl (function list)
  "Apply FUNCTION to all sublists in LIST and return LIST."
  (check-type function function)
  (flet ((helper (list)
           (loop :for item :in list
                 :when (listp item)
                   :do (recursive-mapl function item)
                       (mapl function item))))
    (helper list))
  list)
