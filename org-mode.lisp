;; This is very much a work in progress!  Nowhere near ready for use yet.

(defpackage :lem-tealeg-org-mode
  (:use :cl
        :lem
        :lem.language-mode
        :lem.language-mode-tools
)
  (:export :*org-mode-hook*))
(in-package :lem-tealeg-org-mode)


(lem:define-attribute syntax-org-heading
  (:light :foreground "#ff00ff")
  (:dark :foreground "LightSteelBlue"))

(lem:define-attribute syntax-org-inline-code
  (t :background "#888888" :foreground "#ff0000"))

(lem:define-attribute syntax-org-bold
  (t :bold-p t))

(lem:define-attribute syntax-org-bold
  (t :italic-p t))


(defun make-tmlanguage-org ()
  (let* ((patterns (make-tm-patterns
                    (make-tm-match "^\\*+.*$" :name 'syntax-org-heading)
                    (make-tm-string-region "=" :name 'syntax-org-inline-code)
                    (make-tm-string-region "*" :name 'syntax-org-bold)
                    (make-tm-string-region "/" :name 'syntax-org-italic)



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
