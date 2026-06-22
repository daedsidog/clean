(uiop:define-package #:clean
  (:use-reexport #:clean/aliases
                 #:clean/list-extensions
                 #:clean/package-extensions
                 #:clean/string-extensions
                 #:clean/mop-extensions)
  (:shadowing-import-from #:clean/mop-extensions #:defclass #:defstruct))

(in-package #:clean)

#+sbcl
(progn
  (sb-ext:lock-package 'clean)
  (sb-ext:lock-package 'clean/aliases)
  (sb-ext:lock-package 'clean/list-extensions)
  (sb-ext:lock-package 'clean/package-extensions)
  (sb-ext:lock-package 'clean/string-extensions)
  (sb-ext:lock-package 'clean/mop-extensions))
