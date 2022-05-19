(defsystem "lem-tealeg-vale"
  :depends-on ("lem-core"
               "cl-json")
  :serial t
  :components ((:file "vale")))
