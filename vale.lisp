(defpackage :lem-tealeg-vale
  (:use :cl :lem :cl-json :lem-tealeg-util)
  (:export :vale))

(in-package :lem-tealeg-vale)


(defun run-vale (buffer)
  (with-output-to-string (output)
    (handler-case 
        (uiop:run-program (format nil "vale --output JSON '~A'" (buffer-filename buffer))
                          :ignore-error-status nil
                          :directory (buffer-directory buffer)
                          :output output
                          :error-output output)
      (uiop:subprocess-error (c)
        (let ((code (uiop:subprocess-error-code c)))
          (unless (= code 1)
            (message (format nil "Error in Vale:~A%" c )))
          output)))))


(defun run-vale-all (buffer)
  (with-output-to-string (output)
    (let ((proj-root (find-root-pathname (buffer-directory buffer)
                                         '(".vale.ini"))))
      (handler-case (uiop:run-program (format nil "vale --output JSON '~A'" proj-root)
                                      :ignore-error-status nil
                                      :directory proj-root
                                      :output output
                                      :error-output output)
        (error (c)
          (message (format nil "Error in Vale: ~A%~A" c output))
          nil)))))


(defun parse-vale-output (text)
  (with-input-from-string (in text)
    (decode-json in)))

(defun sourcelist-message (sourcelist msg buffer)
  (lem.sourcelist:append-sourcelist 
   sourcelist
   (lambda (point)
     (insert-string point msg))
   (lambda (set-buffer-fn)
     (funcall set-buffer-fn buffer))))

(defun sourcelist-vale-item (sourcelist note buffer)
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
       (funcall set-buffer-fn buffer)))))

(define-command vale () ()
  (let* (
         (buffer (current-buffer))
         (spinner (lem.loading-spinner:start-loading-spinner
                               :modeline
                               :loading-message "vale"
                               :buffer buffer))
         (output (parse-vale-output (run-vale buffer))))
    (lem.sourcelist:with-sourcelist (sourcelist "*vale*")
      (cond ((null output) (sourcelist-message sourcelist "No findings" buffer))
            ((assoc :*Code output)
             (sourcelist-message sourcelist (cdr (assoc :*Text output)) buffer))
            (t
             (let ((notes (if output (cdr (car output)) nil)))
               (dolist (note notes)
                 (sourcelist-vale-item sourcelist note buffer))))))
    (lem.loading-spinner:stop-loading-spinner spinner)))
  
    

  ;; Not yet working because file paths are converted to keywords by cl-json :-(
  (define-command vale-all () ()
    (let* ((buffer (current-buffer))
           (output (parse-vale-output (run-vale-all buffer))))
      (when output
        (lem.sourcelist:with-sourcelist (sourcelist "*vale*")
          (dolist (f-notes output)
            (let ((source (car f-notes))
                  (notes (cdr f-notes)))
              (dolist (note notes)
                (let ((line (cdr (assoc :*LINE note)))
                      (col (cadr (assoc :*SPAN note)))
                      (severity (cdr (assoc :*SEVERITY note)))
                      (description (cdr (assoc :*MESSAGE note))))
                  (lem.sourcelist:append-sourcelist
                   sourcelist
                   (lambda (point)
                     (insert-string point (princ-to-string source)
                                    :attribute 'lem.sourcelist:title-attribute)
                     (insert-character point #\:)
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
                     (let ((buf (lem:find-file-buffer source))
                           (point (buffer-point buffer)))
                       (move-to-line point line)
                       (move-to-column point (1- col))
                       (funcall set-buffer-fn buf))))))))))))
