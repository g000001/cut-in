;;;; cut-in.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :cut-in
  :serial t
  :depends-on (:fiveam
               :named-readtables)
  :components ((:file "package")
               (:file "readtable")
               (:file "cut-in")
               (:file "test")))


(defmethod perform ((o test-op) (c (eql (find-system :cut-in))))
  (load-system :cut-in)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :cut-in.internal :cut-in))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
