(:mallet-config
  (:extends :default)
  (:enable :line-length :max 100)
  (:enable :no-package-use :allow ("CLEAN" "CLEAN/ALIASES"))
  (:disable :bare-float-literal))
