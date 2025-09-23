;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defsystem #:ck-clle
  :depends-on (#:alexandria #:closer-mop #:hash-set)
  :components ((:module "source"
                :components ((:file "list-extensions")
                             (:file "package-extensions")
                             (:file "string-extensions")
                             (:file "mop-extensions")
                             (:file "clle"
                              :depends-on ("list-extensions" "package-extensions"
                                           "string-extensions" "mop-extensions"))))))

(defsystem #:ck-clle/tests
  :depends-on (#:ck-clle #:fiveam)
  :components ((:module "tests"
                :components ((:file "mop-extensions-test")
                             (:file "tests" :depends-on ("mop-extensions-test"))))))