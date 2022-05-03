(defpackage :lem-tealeg-org-mode
  (:use :cl
        :lem
        :lem.language-mode)
  (:export :*org-mode-hook*))
(in-package :lem-tealeg-org-mode)

(defun make-tmlanguage-org ()
  (let* ((patterns (make-tm-patterns
                    (make-tm-match "^\\*+ " :name 'syntax-constant-attribute)
                    ;; (make-tm-match "=.*=" :name 'syntax-string-attribute)
                    ;; (make-tm-region '(:sequence "#+(BEGIN|begin)")
                    ;;                 '(:sequence "#+(END|end)")
                    ;;                 :name 'syntax-string-attribute
                    ;;                 :patterns (make-tm-patterns (make-tm-match "\\\\.")))
                    ;; (make-tm-region '(:sequence ":.*:")
                    ;;                 '(:sequence ":(END|end):")
                    ;;                 :name 'syntax-string-attribute
                    ;;                 :patterns (make-tm-patterns (make-tm-match "\\\\.")))
                    ;; (make-tm-match "(\\[fn:.?\\])"
                    ;;                :name 'syntax-comment-attribute)
                    ;; (make-tm-match "([-*_] ?)([-*_] ?)([-*_] ?)+"
                    ;;                :name 'syntax-comment-attribute)
                    ;; (make-tm-match "^ *([+\\-]|([0-9]+\\.)) +"
                    ;;                :name 'syntax-keyword-attribute))))
                    )))
    (make-tmlanguage :patterns patterns)))


(defvar *org-syntax-table*
  (let ((table (make-syntax-table
                :space-chars '(#\space #\tab #\newline)
                :string-quote-chars '(#\`)))
        (tmlanguage (make-tmlanguage-org)))
    (set-syntax-parser table tmlanguage)
    table))

(define-major-mode org-mode language-mode
    (:name "Org"
     :keymap *org-mode-keymap*
     :syntax-table *org-syntax-table*
     :mode-hook *org-mode-hook*)
  (setf (variable-value 'enable-syntax-highlight) t
        (variable-value 'indent-tabs-mode) nil
        (variable-value 'tab-width) 4))
        

(pushnew (cons "\\.org$" 'org-mode) *auto-mode-alist*)
