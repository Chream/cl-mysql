;; $Id$

(asdf:defsystem #:cl-mysql-test
  :depends-on (#:cl-mysql
	       #:stefil)
  :components ((:file "test")
	       (:file "test-pool")
	       (:file "integration-test")) 
  :serial t)
