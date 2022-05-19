;; Work in progress - Don't use this, its really buggy

(defpackage :waspell
  (:use :cl :lem :lem-base :enchant)
  (:export :waspell-word-at-point :waspell-check-last-word :*waspell-language* :*waspell-mode-keymap*))


(in-package :waspell)

(defvar *waspell-mode-keymap* (make-keymap :name '*waspell-mode-keymap*
                                           :parent *global-keymap*))


(defvar non-spellable-chars '(
                              (#\Space . "Space")
                              (#\Newline . nil)
                              #\Backspace
                              (#\Tab  . "Tab")
                              (#\Linefeed . nil)
                              (#\Page . nil)
                              (#\Return . "Return")
                              (#\Rubout . nil)
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

(defvar *waspell-overlays* (make-hash-table))

(define-attribute incorrect-spelling-attribute
  (t :background "red"))

(defvar *waspell-broker*
  (broker-init))

(defvar *waspell-language* "en_GB" "The name (typically the ISO 639-1 locale code) of the language dictioary you wish to spellcheck with.")



(defun empty-string-p (s)
  (= (length (string-trim '(#\Space #\Newline #\Backspace #\Tab #\Linefeed #\Page #\Return #\Rubout) s)) 0))

(defun non-spellable-char-p (chr)
  (labels ((nsc-p (c lst) 
                  (if lst
                      (let ((elt (car lst))
                            (rest (cdr lst)))
                        (or (eq c elt) 
                            (and (consp elt) (eq c (car elt)))
                            (nsc-p c rest)))
                      lst)))
    (nsc-p chr non-spellable-chars)))


(defun spellable-char-p (c)
  (not (non-spellable-char-p c)))

(defun point-to-key (point) 
  (format nil "~s" point))

(defun current-word (point)
  (with-point ((cur point)
               (end point))
    (when (non-spellable-char-p (character-at cur))
        (skip-chars-backward cur #'non-spellable-char-p))
    (move-point end cur)
    (skip-chars-backward cur #'spellable-char-p)
    (values (points-to-string cur end) cur end)))


(define-command waspell-check-last-word () ()
  (with-point ((cp (current-point)))
    (let ((c (insertion-key-p (last-read-key-sequence))))
      (insert-character cp c))
  (multiple-value-bind (word start end) (current-word cp)
    (message "checking word ~a" word)
    (with-dict (lang *waspell-language* *waspell-broker*)
      (let* ((key (point-to-key start))
             (ov (gethash key *waspell-overlays*)))
        (if (dict-check lang word)
            (and ov (delete-overlay ov) (remhash key *waspell-overlays*))
            (setf (gethash key *waspell-overlays*)
              (make-overlay start end 'incorrect-spelling-attribute))))))))


(define-command waspell-word-at-point () () 
  (lem.completion-mode:run-completion (lambda (point)
                                        (multiple-value-bind (word start end) (current-word point)
                                          (let* ((key (point-to-key start))
                                                 (ov (gethash key *waspell-overlays*)))
                                            (and ov (delete-overlay ov) (remhash key *waspell-overlays*)))
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

(define-minor-mode waspell-mode 
    (:name "waspell"
     :keymap *waspell-mode-keymap*))



;; (loop for k in non-spellable-chars 
;;        do (progn 
;;             (if (consp k)
;;                 (unless (null (cdr k))
;;                   (define-key *waspell-mode-keymap* (cdr k) 'waspell-check-last-word))
;;                 (define-key *waspell-mode-keymap* (string k) 'waspell-check-last-word))
;;             ))

