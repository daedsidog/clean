;;;; Copyright (C) 2024 DAEDSIDOG.  All rights reserved.

(defsystem #:clean
  :depends-on (#:alexandria #:closer-mop #:trivial-package-local-nicknames)
  :components ((:module "source"
                :components ((:file "preamble")
                             (:file "list-extensions"
                              :depends-on ("preamble"))
                             (:file "package-extensions"
                              :depends-on ("preamble"))
                             (:file "string-extensions"
                              :depends-on ("preamble"))
                             (:file "mop-extensions"
                              :depends-on ("preamble"))
                             (:file "package"
                              :depends-on ("preamble"
                                           "list-extensions"
                                           "package-extensions"
                                           "string-extensions"
                                           "mop-extensions"))))))

(defsystem #:clean/tests
  :depends-on (#:clean #:fiveam)
  :components ((:module "tests"
                :components ((:file "mop-extensions-tests")
                             (:file "package" :depends-on ("mop-extensions-tests"))))))
