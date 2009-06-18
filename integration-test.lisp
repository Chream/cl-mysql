(in-package cl-mysql-test)

(defparameter *z* 1)
(defparameter *z-mutex* (cl-mysql-system:make-lock nil))

(defun reset-z ()
  (cl-mysql-system:with-lock *z-mutex*
    (setf *z* 0)))

(defun z ()
  (cl-mysql-system:with-lock *z-mutex*
    (incf *z*)))

(defun setup-test-database (min max)
  (reset-z)
  (setf (min-connections *conn*) min)
  (setf (max-connections *conn*) max)
  (query "DROP DATABASE IF EXISTS cl_mysql_test; CREATE DATABASE cl_mysql_test; 
                  GRANT ALL ON cl_mysql_test.* TO USER(); FLUSH PRIVILEGES;"
	 :database *conn*)
  (use "cl_mysql_test" :database *conn*)
  (query "CREATE TABLE X ( X INT, T TIMESTAMP DEFAULT CURRENT_TIMESTAMP )" :database *conn*))

(defun long-test (n)
  "Loop from 1 to"
  (setup-test-database 1 2)
  (cl-mysql-system:wait-on-threads
   (loop for i from 1 to n
       collect (progn
                 (sleep  0.01)
                 (princ ".")
                 (generic-start-thread-in-nsecs
                  (lambda (db)
                    (query
                     (format nil  "USE cl_mysql_test; INSERT INTO X (X)  VALUES (~D)" (z))
                     :database db)) (random 5)  *conn*))))
  (unless (equalp (/ (+ n 1) 2)
		  (first (nth-row (query "SELECT AVG(X) FROM X" :database *conn*) 0)))
    (error "Long test didn't have correct result!"))
  t)
