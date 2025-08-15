(defsystem #:ck-clle
  :depends-on (#:alexandria #:closer-mop #:hash-set)
  :components ((:module "source"
                :components ((:file "list")
                             (:file "package")
                             (:file "string")
                             (:file "mop")
                             (:file "clle"
                              :depends-on ("list" "package" "string" "mop"))))))

(defsystem #:ck-clle/tests
  :depends-on (#:ck-clle #:fiveam)
  :components ((:module "tests"
                :components ((:file "mop-test")
                             (:file "tests" :depends-on ("mop-test"))))))