(defpackage #:clean/string-extensions
  (:use #:cl)
  (:import-from #:clean/aliases #:nullp #:dispatch-macro-character)
  (:import-from #:cl-interpol #:interpol-reader)
  (:export #:prefix-string #:string-empty-p))

(in-package #:clean/string-extensions)

(setf (dispatch-macro-character #\# #\?) #'interpol-reader)

(defun string-empty-p (string)
  "Return T if STRING contains no characters or is nil."
  (or (nullp string) (zerop (length string))))

(defun prefix-string (string prefix &optional (skip-first-line nil))
  "Return STRING prefixed with PREFIX prepended to each line, with the first line not prefixed if
SKIP-FIRST-LINE is not nil."
  (when (or (string-empty-p string)
            (string-empty-p prefix))
    (return-from prefix-string string))
  (with-output-to-string (out)
    (with-input-from-string (in string)
      (let ((is-first-line t))
        (loop :for line = (read-line in nil nil)
              :while line
              :do (if is-first-line
                      (progn
                        (setf is-first-line nil)
                        (unless skip-first-line
                          (format out "~A" prefix))
                        (format out "~A" line))
                      (format out "~%~A~A" prefix line)))))
    out))
