(defpackage :lem-tealeg-modeline-clock
  (:use :cl :lem)
  (:export :enable
           :disable
           :modeline-clock-timer))

(in-package :lem-tealeg-modeline-clock)

(defun modeline-clock (window)
  (declare (ignore window))
  (multiple-value-bind 
        (second minute hour date month year day-number dst tz) (get-decoded-time)
    (declare (ignore day-number)
             (ignore dst)
             (ignore tz))
    (apply #'values (list (format nil "~2,'0d:~2,'0d:~2,'0d  ~d/~2,'0d/~d  "
                          hour
                          minute
                          second
                          date
                          month
                          year)
                          nil
                          :right))))

(defvar modeline-clock-timer
  (sb-ext:make-timer #'lem:redraw-display)
  "A timer to make the modeline redraw periodically, instaed of just on activity")

(defun enable ()
  (sb-ext:schedule-timer modeline-clock-timer 1 :repeat-interval 1)
  (modeline-add-status-list 'modeline-clock))


(defun disable () 
  (when (sb-ext:timer-scheduled-p modeline-clock-timer)
      (sb-ext:unschedule-timer modeline-clock-timer))
  (modeline-remove-status-list 'modeline-clock))


