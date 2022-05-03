(defpackage :lem-tealeg-modeline-clock
  (:use :cl :lem)
  (:export :enable
           :disable))

(in-package :lem-tealeg-modeline-clock)

(defconstant day-names
    '("Monday" "Tuesday" "Wednesday"
      "Thursday" "Friday" "Saturday"
      "Sunday"))

(defun clock (window)
  (declare (ignore window))
  (multiple-value-bind 
        (second minute hour date month year day-of-week dst-p tz) (get-decoded-time)
    (apply #'values (list (format t "~2,'0d:~2,'0d:~2,'0d of ~a, ~d/~2,'0d/~d (UTC~@d)"
                          hour
                          minute
                          second
                          (nth day-of-week day-names)
                          date
                          month
                          year
                          (if dst-p 
                              (- (+ tz 1)) 
                              (- tz)))
                  nil
                  :right))))

(defun enable ()
  (modeline-add-status-list 'clock))


(defun disable () 
  (modeline-remove-status-list 'clock))