;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :cut-in
  (:use)
  (:export :cut-in))


(defpackage :cut-in.internal
  (:use :cut-in :cl :named-readtables :fiveam))

