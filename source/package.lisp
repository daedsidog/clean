;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(uiop:define-package #:clean
    (:use #:cl)
  (:shadowing-import-from #:clean/preamble #:equalp)
  (:shadowing-import-from #:clean/mop-extensions #:defclass)
  (:reexport #:cl)
  (:use-reexport #:clean/preamble
                 #:clean/list-extensions
                 #:clean/package-extensions
                 #:clean/string-extensions
                 #:clean/mop-extensions))

(in-package #:clean)

#+sbcl
(progn
  (sb-ext:lock-package 'clean)
  (sb-ext:lock-package 'clean/preamble)
  (sb-ext:lock-package 'clean/list-extensions)
  (sb-ext:lock-package 'clean/package-extensions)
  (sb-ext:lock-package 'clean/string-extensions)
  (sb-ext:lock-package 'clean/mop-extensions))
