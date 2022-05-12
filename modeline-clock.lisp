(defpackage :lem-tealeg-modeline-clock
  (:use :cl :lem :local-time)
  (:export :enable
           :disable
           :modeline-clock-timer))

(in-package :lem-tealeg-modeline-clock)

(defvar lem-user::*modeline-clock-format*
  '((:hour 2) ":" (:min 2) ":" (:sec 2) " " :year  "-" (:month 2) "-" (:day 2) " ")
  "The format for displaying the time and/or date in the modeline. Expressed using the local-time library's syntax: https://github.com/dlowe-net/local-time")

(defvar lem-user::*modeline-clock-refresh-interval*
  1
  "The time to wait, in seconds, between updates to the clock.  Defaults to 1.")

(defun modeline-clock (window)
  (declare (ignore window))
  (apply #'values (list (local-time:format-timestring nil (local-time:now) :format lem-user::*modeline-clock-format*) nil :right)))

(defvar *modeline-clock-timer* nil
  "A timer to make the modeline redraw periodically, instead of just on activity")

(defun enable ()
  (lem:start-timer 1000 t #'lem:redraw-display nil "modeline clock timer")
  (modeline-add-status-list 'modeline-clock))


(defun disable () 
  (when *modeline-clock-timer*
    (lem:stop-timer *modeline-clock-timer*))
  (modeline-remove-status-list 'modeline-clock))


