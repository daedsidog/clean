(defsystem "clean"
  :depends-on ("alexandria" "closer-mop" "trivial-package-local-nicknames")
  :serial t
  :components ((:module "source"
                :serial t
                :components ((:file "aliases")
                             (:file "list-extensions")
                             (:file "package-extensions")
                             (:file "string-extensions")
                             (:file "mop-extensions")
                             (:file "package")))))

(defsystem "clean/tests"
  :depends-on ("clean" "fiveam")
  :serial t
  :components ((:module "tests"
                :serial t
                :components ((:file "mop-extensions-test")
                             (:file "package")))))
