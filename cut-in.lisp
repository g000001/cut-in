;;;; cut-in.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cut-in.internal)


(eval-when (:compile-toplevel :load-toplevel :execute)


  (defun cut-in.print (ans expr pos)
    `(let ((,ans (multiple-value-list ,expr)))
       (format *debug-io* 
               "~2&~
                ;;; ~A~%~
                ;;;~%~
                ;;; ~S => ~{~S~^, ~}~2%" 
               ,pos
               ',expr 
               ,ans)
       (values-list ,ans)))


  (defun cut-in.break (ans expr pos)
    `(let ((,ans (multiple-value-list ,expr)))
       (break "~2&~
               ;;; ~S => ~{~S~^, ~}~2%~A~%" 
              ',expr
              ,ans
              ,pos)
       (values-list ,ans)))


  (defun cut-in.time (ans expr pos)
    `(let ((,ans (multiple-value-list ,expr)))
       (format *debug-io*
               "~2&~
                ;;; ~A~%~
                ;;;~%~
                ;;; ~S => ~{~S~^, ~}~2%"
               ,pos
               ',expr
               ,ans)
       (time (values-list ,ans))))


  (defun cut-in.fn (fn ans expr pos)
    `(let ((,ans (multiple-value-list ,expr)))
       (format *debug-io*
               "~2&~
                ;;; ~A~%~
                ;;;~%~
                ;;; ~S => ~{~S~^, ~}~2%"
               ,pos
               ',expr
               ,ans)
       (mapc (lambda (x) 
               (let* ((*standard-output* *debug-io*))
                 (,fn x)))
             ,ans)
       (values-list ,ans)))


  (defun cut-in.type (ans expr pos typespec)
    `(let ((,ans (multiple-value-list (the ,typespec ,expr))))
       (format *debug-io* 
               "~2&~
                ;;; ~A~%~
                ;;;~%~
                ;;; ~S => ~{~S~^, ~}~2%" 
               ,pos
               ',expr 
               ,ans)
       (values-list ,ans)))

  
  #|(declaim (inline definition-source-location-emacs-filename&position))|#
  #|(defun definition-source-location-emacs-filename&position ()
  (let* ((plist 
  #+:sbcl (sb-c:definition-source-location-plist (sb-c:source-location))
  #-:sbcl '()))
  (format nil 
  "file://~A:~D" 
  (getf plist :emacs-filename)
  (getf plist :emacs-position))))|#


  (defun valid-type-specifier-p (spec)
    #+:sbcl (sb-ext:valid-type-specifier-p spec)
    #-:sbcl nil) )


(defmacro definition-source-location-emacs-filename&position (&aux (plist (gensym)))
  `(let* ((,plist
           (or
            #+:sbcl (sb-c:definition-source-location-plist
                     (sb-c:source-location))
            #+:lispworks `(:emacs-filename ,(def:location)
                           :emacs-position ""))))
     (format nil 
             "file://~A:~D" 
             (getf ,plist :emacs-filename)
             (getf ,plist :emacs-position))))


(defmacro cut-in (kind expr)
  (let ((ans (gensym "ans-"))
        (pos (gensym "pos-")))
    `(let ((,pos (definition-source-location-emacs-filename&position)))
       (declare (ignorable ,pos))
       ,(if (consp kind)
            (cond ((valid-type-specifier-p kind)
                   (cut-in.type ans expr pos kind))
                  ((eq 'cl:lambda (car kind))
                   (cut-in.fn kind ans expr pos))
                  (T expr))
            (cond ((valid-type-specifier-p kind)
                   (cut-in.type ans expr pos kind))
                  ((every (lambda (c) (char= #\> c)) (string kind))
                   (cut-in.print ans expr pos))
                  ((string-equal :nop kind)
                   expr)
                  ((string-equal :break kind)
                   (cut-in.break ans expr pos))
                  ((string-equal :time kind)
                   (cut-in.time ans expr pos))
                  ((fboundp kind)
                   (cut-in.fn kind ans expr pos))
                  (T expr))))))


;;; *EOF*
