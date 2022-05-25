(defsystem "lem-tealeg-linkcheck"
  :depends-on ("lem-core" "cl-async" "lem-tealeg-util" )
  :serial t
  :components ((:file "linkcheck")))