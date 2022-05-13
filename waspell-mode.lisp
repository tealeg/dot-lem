;; Work in progress - you can spellcheck a word allready, in en_GB, but that's it

(defpackage :waspell
  (:use :cl :lem :enchant)
  (:export :waspell-word-at-point))


(in-package :waspell)

(defvar *overlays* '())

(defvar *waspell-mode-keymap*
  (make-keymap :name '*waspell-mode-keymap*))

(define-minor-mode waspell-mode 
    (:keymap *waspell-mode-keymap*
     :name "waspell"))


(defun current-word (point)
  (with-point ((cur point)
               (end point))
    (skip-symbol-backward cur)
    (skip-symbol-forward end)
    (points-to-string cur end)))


(define-command waspell-word-at-point () () 
  (lem.completion-mode:run-completion (lambda (point)
   (let ((word (current-word point)))
     (with-dict (lang "en_GB")
       (unless (dict-check lang word)
         (let ((words (dict-suggest lang word)))
           (with-point ((start point)
                        (end point))
             (skip-chars-backward start #'syntax-symbol-char-p)
             (mapcar (lambda (word)
                       (lem.completion-mode:make-completion-item :label word
                                                                 :start start
                                                                 :end end))
                     words)))))))))



