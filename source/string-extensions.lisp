;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defpackage #:ck-clle/string-extensions
  (:use #:cl)
  (:export #:indent-string #:string-empty-p))

(in-package #:ck-clle/string-extensions)

(defun string-empty-p (string)
  (not (loop :for char :across string :thereis char)))

(defun indent-string (string indentation-string)
  "Prepend INDENTATION-STRING to each line in STRING."
  (with-output-to-string (out)
    (with-input-from-string (in string)
      (let ((is-first-line t))
        (loop :for line = (read-line in nil nil)
              :while line
              :do (if is-first-line
                    (setf is-first-line nil)
                    (format out "~%"))
                  (format out "~A~A" indentation-string line))))
    out))
