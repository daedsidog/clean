(defsystem #:ck-clle
  :depends-on (#:alexandria)
  :components ((:module "source"
                :components ((:file "list")
                             (:file "package")
                             (:file "string")
                             (:file "clle" :depends-on ("list" "package" "string"))))))
