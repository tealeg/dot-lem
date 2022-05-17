;; Work in progress - you can spellcheck a word allready, in en_GB, but that's it

(defpackage :waspell
  (:use :cl :lem :lem-base :enchant)
  (:export :waspell-word-at-point :waspell-check-last-word :*waspell-language* :*waspell-mode-keymap*))


(in-package :waspell)

(define-minor-mode waspell-mode 
    (:keymap *waspell-mode-keymap*
     :name "waspell"))

(defvar non-spellable-chars '(#\Space
              #\Newline
              #\Backspace
              #\Tab 
              #\Linefeed
              #\Page 
              #\Return
              #\Rubout
              #\"
              #\'
              #\!
              #\@
              #\#
              #\$
              #\%
              #\^
              #\&
              #\*
              #\-
              #\=
              #\_
              #\+
              #\\
              #\|
              #\`
              #\~
              #\;
              #\:
              #\,
              #\.
              #\<
              #\>
              #\/
              #\?
              #\( 
              #\)
              #\[
              #\]
              #\{
              #\}
              #\0
              #\1
              #\2
              #\3
              #\4
              #\5
              #\6
              #\7
              #\8
              #\9)
  "The list of all chars that we cannot spellcheck on ")

;; (mapc (lambda (c) (define-key *waspell-mode-keymap* (string c) 'waspell-check-last-word)) non-spellable-chars)


(defvar *waspell-overlays* '())

(define-attribute incorrect-spelling-attribute
  (t :background "red"))

(defvar *waspell-broker*
  (broker-init))

(defvar *waspell-language* "en_GB" "The name (typically the ISO 639-1 locale code) of the language dictioary you wish to spellcheck with.")



(defun empty-string-p (s)
  (= (length (string-trim '(#\Space #\Newline #\Backspace #\Tab #\Linefeed #\Page #\Return #\Rubout) s)) 0))

(defun non-spellable-char-p (c)
  (member c non-spellable-chars))


(defun spellable-char-p (c)
  (not (non-spellable-char-p c)))


(defun current-word (point)
  (with-point ((cur point)
               (end point))
    (if (non-spellable-char-p (character-at cur))
        (skip-chars-backward cur #'non-spellable-char-p) 
        (skip-chars-forward cur #'spellable-char-p))
    (move-point end cur)
    (skip-chars-backward cur #'spellable-char-p)
    (values (points-to-string cur end) cur end)))


(define-command waspell-check-last-word () ()
  (mapc #'delete-overlay *waspell-overlays*)
  (multiple-value-bind (word start end) (current-word (current-point))
    (with-dict (lang *waspell-language* *waspell-broker*)
      (unless (dict-check lang word)
        (push (make-overlay start end 'incorrect-spelling-attribute)
              *waspell-overlays*)))))
        

(define-command waspell-word-at-point () () 
  (mapc #'delete-overlay *waspell-overlays*)
  (lem.completion-mode:run-completion (lambda (point)
                                        (multiple-value-bind (word start end) (current-word point)
                                          (with-dict (lang *waspell-language* *waspell-broker*)
                                            (unless (dict-check lang word)
                                              (let ((words (dict-suggest lang word)))
                                                  (skip-chars-backward start #'non-spellable-char-p)
                                                (mapcar (lambda (word)
                                                          (lem.completion-mode:make-completion-item :label word
                                                                                                    :start start
                                                                                                    :end end))
                                                        words))))))))

;; (defun scan-spelling (start end)
;;   (with-point ((p1 start)
;;                (p2 start)
;;                (end end))
;;     (line-start p1)
;;     (line-end end)
;;     (mapc #'delete-overlay *waspell-overlays*)
;;     (with-dict (lang *waspell-language* *waspell-broker*)
;;       (loop :while (point< p1 end)
;;             :do (skip-chars-forward p2 #'non-spellable-char-p)
;;                 (move-point p1 p2)
;;                 (skip-chars-forward p2 #'spellable-char-p)
;;                 (let ((word (points-to-string p1 p2)))
;;                   (unless (or (empty-string-p word) (dict-check lang word))
;;                     (push (make-overlay p1 p2 'incorrect-spelling-attribute)
;;                           *waspell-overlays*))
;;               )))))


(define-key  *waspell-mode-keymap* #\Space 'waspell-check-last-word)
(loop for k in non-spellable-chars 
      do (define-key *waspell-mode-keymap* k 'waspell-check-last-word))

;  ;; (add-hook  (variable-value 'after-syntax-scan-hook :global)
  ;;           'scan-spelling))

;; (defun disable ()
;; )
  ;; (remove-hook (variable-value 'after-syntax-scan-hook :global)
  ;;              'scan-spelling))
