(defpackage :lem-tealeg-vale
  (:use :cl :lem :cl-json)
  (:export :vale))

(in-package :lem-tealeg-vale)


(defun run-vale (buffer)
  (with-output-to-string (output)
    (uiop:run-program (format nil "vale --output JSON '~A'" (buffer-filename buffer))
                              :ignore-error-status t
                              :directory (buffer-directory buffer)
                              :output output
                              :error-output output)))

(defun parse-vale-output (text)
  (with-input-from-string (in text)
    (let ((json (decode-json in)))
      (if json
          (cdr (car json))
          nil))))

(define-command vale () ()
  (let* ((buffer (current-buffer))
         (notes (parse-vale-output (run-vale buffer))))
    (lem.sourcelist:with-sourcelist (sourcelist "*vale*")
      (dolist (note notes)
        (let ((line (cdr (assoc :*LINE note)))
              (col (cadr (assoc :*SPAN note)))
              (severity (cdr (assoc :*SEVERITY note)))
              (description (cdr (assoc :*MESSAGE note))))
        (lem.sourcelist:append-sourcelist
         sourcelist
         (lambda (point)
             (insert-string point (princ-to-string line)
                            :attribute 'lem.sourcelist:position-attribute)
             (insert-character point #\:)
             (insert-string point (princ-to-string col)
                            :attribute 'lem.sourcelist:position-attribute)
             (insert-character point #\:)
             (insert-string point severity)
             (insert-character point #\:)
             (insert-string point description))
         (lambda (set-buffer-fn)
           (let ((point (buffer-point buffer)))
             (move-to-line point line)
             (move-to-column point (1- col)))
           (funcall set-buffer-fn buffer))))))))

                       
        
    

                             