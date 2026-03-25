;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defsystem #:clean
  :depends-on (#:alexandria #:closer-mop #:trivial-package-local-nicknames)
  :components ((:module "source"
                :components ((:file "list-extensions")
                             (:file "package-extensions")
                             (:file "string-extensions")
                             (:file "mop-extensions")
                             (:file "package"
                              :depends-on ("list-extensions" "package-extensions"
                                           "string-extensions" "mop-extensions"))))))

(defsystem #:clean/tests
  :depends-on (#:clean #:fiveam)
  :components ((:module "tests"
                :components ((:file "mop-extensions-tests")
                             (:file "package" :depends-on ("mop-extensions-tests"))))))
