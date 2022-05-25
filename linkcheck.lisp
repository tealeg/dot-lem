(defpackage :lem-tealeg-linkcheck
  (:use :cl
        :lem
        :lem-tealeg-util)
  (:export :linkcheck))

(in-package :lem-tealeg-linkcheck)




(defun run-linkcheck (buffer)
  (with-output-to-string (output)
    (let* ((proj-root (find-root-pathname
                       (buffer-directory buffer)
                       '("linkcheck.sh")))
           (cmd (format nil "~A -e"
                        (merge-pathnames
                         #P"linkcheck.sh"
                         proj-root))))
      (uiop:run-program cmd
                        :ignore-error-status t
                        :directory proj-root
                        :output output
                        :error-output output))))
  
(defun parse-linkcheck-output (text)
  (with-input-from-string (in text) 
    (loop :for line := (read-line in nil)
          :while line
          :for result := (ppcre:register-groups-bind (source line-number column target)
                             ("^(.*):(\\d+):(\\d+):(.*)$" line)
                           (setq line-number (parse-integer line-number)
                                 column (parse-integer column))
                           (list source line-number column target))
          :when result
          :collect it)))

(defun linkcheck-sourcelist (notes)
    (lem.sourcelist:with-sourcelist (sourcelist "*linkcheck*")
      (dolist (note notes)
        (destructuring-bind (source line-number column target) note
          (lem.sourcelist:append-sourcelist
           sourcelist
           (lambda (point)
             (insert-string point (pathname-name source)
                            :attribute 'lem.sourcelist:title-attribute)
             (insert-character point #\.)
             (insert-string point (pathname-type source)
                            :attribute 'lem.sourcelist:title-attribute)
             (insert-character point #\:)
             (insert-string point (princ-to-string line-number)
                            :attribute 'lem.sourcelist:position-attribute)
             (insert-character point #\:)
             (insert-string point (princ-to-string column)
                            :attribute 'lem.sourcelist:position-attribute)
             (insert-character point #\:)
             (insert-string point target))
           (lambda (set-buffer-fn)
             (let* ((buf (lem:find-file-buffer source))
                    (point (buffer-point buf)))
               (move-to-line point line-number)
               (move-to-column point (1- column))
               (funcall set-buffer-fn buf))))))))


(define-command linkcheck () () 
  (let* ((buffer (current-buffer))
         (notes (parse-linkcheck-output (run-linkcheck buffer))))
    (linkcheck-sourcelist notes)))


               


