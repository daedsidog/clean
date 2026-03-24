;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defpackage #:clean/string-extensions
  (:use #:cl)
  (:export #:indent-string #:string-empty-p))

(in-package #:clean/string-extensions)

(defun string-empty-p (string)
  "Return T if STRING contains no characters."
  (not (loop :for char :across string :thereis char)))

(defun indent-string (string indentation-string)
  "Return the string indented with INDENTATION-STRING prepended to each line."
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
