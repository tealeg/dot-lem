(defpackage #:lem-tealeg-init
  (:use #:cl
        #:lem))

(in-package :lem-tealeg-init)

(define-key *global-keymap* "C-Return" 'lem.language-mode:newline-and-indent)
(define-key *global-keymap* "Return" 'newline)
(define-key *global-keymap* "C-x u" 'undo)
(setf *scroll-recenter-p* nil)




(let ((asdf:*central-registry* (cons #P"~/.lem/" asdf:*central-registry*)))
  (ql:quickload :lem-tealeg-init)

  (ql:quickload :lem-tealeg-modeline-clock)
  (ql:quickload :lem-tealeg-org-mode)

  ;; (ql:quickload :lem-tealeg-waspell-mode)
  
  (ql:quickload :lem-modeline-battery)

  (ql:quickload :lem-paredit-mode)
  (ql:quickload :lem-tealeg-vale)
  )

(lem-modeline-battery:enable)
(lem-tealeg-modeline-clock:enable)

(lem:load-theme "emacs-light")


