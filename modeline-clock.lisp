(defpackage :lem-tealeg-modeline-clock
  (:use :cl :lem)
  (:export :enable
           :disable))

(in-package :lem-tealeg-modeline-clock)

(defvar tealeg-day-names
     '("Monday" "Tuesday" "Wednesday"
       "Thursday" "Friday" "Saturday"
       "Sunday"))

(defun modeline-clock (window)
  (declare (ignore window))
  (multiple-value-bind 
        (second minute hour date month year day-of-week dst-p tz) (get-decoded-time)
    (apply #'values (list (format nil "~2,'0d:~2,'0d:~2,'0d ~a, ~d/~2,'0d/~d (UTC~@d) "
                          hour
                          minute
                          second
                          (nth day-of-week tealeg-day-names)
                          date
                          month
                          year
                          (if dst-p 
                              (-  (- tz 1))
                              (- tz)))
          nil
          :right))))

(defun enable ()
  (modeline-add-status-list 'modeline-clock))


(defun disable () 
  (modeline-remove-status-list 'modeline-clock))
