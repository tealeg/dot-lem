(defpackage :lem-tealeg-util
  (:use :cl :lem)
  (:export :find-root-pathname))

(in-package :lem-tealeg-util)


(defun find-root-pathname (directory uri-patterns)
  (or (lem-lsp-mode/utils:find-root-pathname directory
                                             (lambda (file)
                                               (let ((file-name (file-namestring file)))
                                                 (dolist (uri-pattern uri-patterns)
                                                   (when (search uri-pattern file-name)
                                                     (return t))))))
      (pathname directory)))

