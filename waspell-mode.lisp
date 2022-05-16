;; Work in progress - you can spellcheck a word allready, in en_GB, but that's it

(defpackage :waspell
  (:use :cl :lem :lem-base :enchant)
  (:export :waspell-word-at-point :*waspell-language*))


(in-package :waspell)

(defvar *waspell-overlays* '())

(define-attribute incorrect-spelling-attribute
  (t :background "red"))

(defvar *waspell-broker*
  (broker-init))

(defvar *waspell-language* "en_GB" "The name (typically the ISO 639-1 locale code) of the language dictioary you wish to spellcheck with.")

(defvar *waspell-mode-keymap*
  (make-keymap :name '*waspell-mode-keymap*))


(define-minor-mode waspell-mode 
    (:keymap *waspell-mode-keymap*
     :name "waspell"
     :enable-hook 'enable
     :disable-hook 'disable)
)


(defun empty-string-p (s)
  (= (length (string-trim '(#\Space #\Newline #\Backspace #\Tab #\Linefeed #\Page #\Return #\Rubout) s)) 0))

(defun non-spellable-char-p (c)
  (member c '(#\Space
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
              #\9)))


(defun spellable-char-p (c)
  (not (non-spellable-char-p c)))


(defun current-word (point)
  (with-point ((cur point)
               (end point))
    (skip-chars-backward cur #'spellable-char-p)
    (skip-chars-forward end #'spellable-char-p)
    (points-to-string cur end)))


(define-command waspell-word-at-point () () 
  (lem.completion-mode:run-completion (lambda (point)
   (let ((word (current-word point)))
     (with-dict (lang *waspell-language* *waspell-broker*)
       (unless (dict-check lang word)
         (let ((words (dict-suggest lang word)))
           (with-point ((start point)
                        (end point))
             (skip-chars-backward start #'non-spellable-char-p)
             (mapcar (lambda (word)
                       (lem.completion-mode:make-completion-item :label word
                                                                 :start start
                                                                 :end end))
                     words)))))))))

(defun scan-spelling (start end)
  (with-point ((p1 start)
               (p2 start)
               (end end))
    (line-start p1)
    (line-end end)
    (mapc #'delete-overlay *waspell-overlays*)
    (with-dict (lang *waspell-language* *waspell-broker*)
      (loop :while (point< p1 end)
            :do (skip-chars-forward p2 #'non-spellable-char-p)
                (move-point p1 p2)
                (skip-chars-forward p2 #'spellable-char-p)
                (let ((word (points-to-string p1 p2)))
                  (unless (or (empty-string-p word) (dict-check lang word))
                    (push (make-overlay p1 p2 'incorrect-spelling-attribute)
                          *waspell-overlays*))
              )))))


(defun enable ()
  (add-hook  (variable-value 'after-syntax-scan-hook :global)
            'scan-spelling))

(defun disable ()
  (remove-hook (variable-value 'after-syntax-scan-hook :global)
               'scan-spelling))
