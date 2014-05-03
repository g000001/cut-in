;;;; readtable.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cut-in.internal)
(in-readtable :common-lisp)


(defun read-until->> (stream)
  (let ((pc nil))
    (loop :for c := (read-char stream)
          :until (and (not (eql #\> (peek-char nil stream)))
                      (eql pc #\>))
          :collect pc :into chars
          :do (setq pc c)
          :finally (return (coerce (cdr chars) 'string)))))


(defreadtable :cut-in
  (:merge :standard)
  (:dispatch-macro-char #\# #\> 
                        (lambda (stream char arg)
                          (declare (ignore char arg))
                          (let ((expr (or (read-from-string 
                                           (read-until->> stream)
                                           nil)
                                          :>)))
                            `(cut-in:cut-in ,expr 
                                            ,(read stream t nil t)))))
  (:case :upcase))


;;; *EOF*
