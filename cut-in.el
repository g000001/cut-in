;; usage:
;; (add-to-list 'slime-edit-definition-hooks #'cut-in-jump-to-cut-in-position)
;; and M-. on file://.... line.

(defun cut-in-jump-to-cut-in-position (name &optional where)
  (when (string-match "\\bfile://\\(.*\\):\\([0-9]+\\)" name)
    (select-window
     (get-buffer-window
      (find-buffer-visiting
       (substring name
                  (match-beginning 1)
                  (match-end 1)))))
    (goto-char
     (parse-integer 
      (substring name
                 (match-beginning 2)
                 (match-end 2))))
    (re-search-forward "#>")))




