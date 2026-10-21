(defclass clean-source-file (cl-source-file)
  ())

;;; Loading CLEAN into an image that already has it updates it in place, which
;;; redefines symbols of the packages the previous load locked.
(defmethod perform :before ((operation operation) (file clean-source-file))
  #+sbcl
  (dolist (package (list-all-packages))
    (when (or (string= (package-name package) "CLEAN")
              (string-prefix-p "CLEAN/" (package-name package)))
      (sb-ext:unlock-package package))))

(defsystem "clean"
  :description "Common-Lisp extensions and normalizations."
  :author "Jan Jouleodov"
  :license "MIT"
  :default-component-class clean-source-file
  :depends-on ("alexandria" "closer-mop" "trivial-package-local-nicknames" "cl-interpol")
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
