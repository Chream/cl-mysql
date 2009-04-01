;;;; -*- Mode: Lisp -*-
;;;; $Id$
;;;; Author: Steve Knight <stknig@gmail.com>
;;;;
(defpackage com.hackinghat.cl-mysql-system
  (:use :cl :cffi)
  (:nicknames "CL-MYSQL-SYSTEM")
  (:export
   ;; Special vairalbes
   #:*type-map*
   ;; Public functions
   #:connect #:query #:use #:disconnect #:ping #:option
   #:client-version #:server-version
   #:list-dbs #:list-tables #:list-processes #:list-fields
   #:escape-string 
   ;; Constants
   #:+client-compress+  #:+client-found-rows+    #:+client-ignore-sigpipe+
   #:+client-ignore-space+  #:+client-interactive+ #:+client-local-files+
   #:+client-multi-statements+  #:+client-multi-results+  #:+client-no-schema+
   #:+client-ssl+  #:+client-remember-options+
   ;; Internal functions
   #:string-to-integer #:string-to-float
   #:string-to-date #:string-to-seconds #:string-to-universal-time
   #:string-to-ratio #:extract-field #:cffi-utf8-length
   ;; Enum Options
   #:opt-connect-timeout #:opt-compress #:opt-named-pipe
   #:init-command #:read-default-file #:read-default-group
   #:set-charset-dir #:set-charset-name #:opt-local-infile
   #:opt-protocol #:shared-memory-base-name #:opt-read-timeout
   #:opt-write-timeout #:opt-use-result
   #:opt-use-remote-connection #:opt-use-embedded-connection
   #:opt-guess-connection #:set-client-ip #:secure-auth
   #:report-data-truncation #:opt-reconnect
   #:opt-ssl-verify-server-cert))

(in-package "CL-MYSQL-SYSTEM")

(define-foreign-library libmysqlclient
  (t (:default "libmysqlclient_r")))

(use-foreign-library libmysqlclient)

;;; Client options
;;;
(defconstant +client-compress+ 32)
(defconstant +client-found-rows+ 2)
(defconstant +client-ignore-sigpipe+ 4096)
(defconstant +client-ignore-space+ 256)
(defconstant +client-interactive+ 1024)
(defconstant +client-local-files+ 128)
(defconstant +client-multi-statements+  (ash 1 16))
(defconstant +client-multi-results+ (ash 1 17))
(defconstant +client-no-schema+ 16)
(defconstant +client-ssl+ (ash 1 11))
(defconstant +client-remember-options+ (ash 1 31))

;;; Field flags
;;;
(defconstant +field-not-null+ 1
  "Field can't be null")
(defconstant +field-primary-key+ 2
  "Field is part of a primary key")
(defconstant +field-unique-key+ 4
  "Field is part of a unique key")
(defconstant +field-multiple-key+ 8
  "Field is part of a key")
(defconstant +field-blob+ 16
  "Field is a blob")
(defconstant +field-unsigned+ 32
  "Field is unsigned")
(defconstant +field-zerofill+ 64
  "Field is zerofill")
(defconstant +field-binary+ 128
  "Field is binary")
(defconstant +field-enum+ 256
  "Field is an enum")
(defconstant +field-auto-increment+ 512
  "Field is auto increment")
(defconstant +field-timestamp+ 1024
  "Field is a timestamp")
(defconstant +field-set+ 2048
  "Field is a set")
(defconstant +field-no-default+ 4096
  "Field doesn't have a default value")
(defconstant +field-num+ 32768
  "Field is num")

;;; Error codes
;;;
(defconstant +commands-out-of-sync+ 2014)
(defconstant +error-first+ 2000)
(defconstant +unknown-error+ 2000)
(defconstant +socket-create-error+ 2001)
(defconstant +connection-error+ 2002)
(defconstant +conn-host-error+ 2003)
(defconstant +ipsock-error+ 2004)
(defconstant +unknown-host+ 2005)
(defconstant +server-gone-error+ 2006)
(defconstant +version-error+ 2007)
(defconstant +out-of-memory+ 2008)
(defconstant +wrong-host-info+ 2009)
(defconstant +localhost-connection+ 2010)
(defconstant +tcp-connection+ 2011)
(defconstant +server-handshake-err+ 2012)
(defconstant +server-lost+ 2013)
(defconstant +commands-out-of-sync+ 2014)
(defconstant +namedpipe-connection+ 2015)
(defconstant +namedpipewait-error+ 2016)
(defconstant +namedpipeopen-error+ 2017)
(defconstant +namedpipesetstate-error+ 2018)
(defconstant +cant-read-charset+ 2019)
(defconstant +net-packet-too-large+ 2020)
(defconstant +embedded-connection+ 2021)
(defconstant +probe-slave-status+ 2022)
(defconstant +probe-slave-hosts+ 2023)
(defconstant +probe-slave-connect+ 2024)
(defconstant +probe-master-connect+ 2025)
(defconstant +ssl-connection-error+ 2026)
(defconstant +malformed-packet+ 2027)
(defconstant +wrong-license+ 2028)
(defconstant +null-pointer+ 2029)
(defconstant +no-prepare-stmt+ 2030)
(defconstant +params-not-bound+ 2031)
(defconstant +data-truncated+ 2032)
(defconstant +no-parameters-exists+ 2033)
(defconstant +invalid-parameter-no+ 2034)
(defconstant +invalid-buffer-use+ 2035)
(defconstant +unsupported-param-type+ 2036)
(defconstant +shared-memory-connection+ 2037)
(defconstant +shared-memory-connect-request-error+ 2038)
(defconstant +shared-memory-connect-answer-error+ 2039)
(defconstant +shared-memory-connect-file-map-error+ 2040)
(defconstant +shared-memory-connect-map-error+ 2041)
(defconstant +shared-memory-file-map-error+ 2042)
(defconstant +shared-memory-map-error+ 2043)
(defconstant +shared-memory-event-error+ 2044)
(defconstant +shared-memory-connect-abandoned-error+ 2045)
(defconstant +shared-memory-connect-set-error+ 2046)
(defconstant +conn-unknow-protocol+ 2047)
(defconstant +invalid-conn-handle+ 2048)
(defconstant +secure-auth+ 2049)
(defconstant +fetch-canceled+ 2050)
(defconstant +no-data+ 2051)
(defconstant +no-stmt-metadata+ 2052)
(defconstant +no-result-set+ 2053)
(defconstant +not-implemented+ 2054)
(defconstant +server-lost-extended+ 2055)

(eval-when (:compile-toplevel)
  (defparameter *generate-alt-fns* nil
    "Compile the library with this value equal to T to get the indirection
   facility.   For more performance (because there is no wrapper around
   the CFFI wrapper!) set this value to NIL")
  (defparameter *mysql-dev-api-url* "http://dev.mysql.com/doc/refman/5.0/en/~A.html"
    "MySQL uses a standard page naming convention that matches our function names!"))

(defmacro defmysqlfun ((name internal-name) return-type &body args)
  "Takes a mysql function name as a string and registers the
   appropriate CFFI function as internal-name.  

   If *generate-alt-fns* is T internal-name that denotes T a wrapper function
   that sits around the function lib<internal-name>.

   This function will call the lib<internal-name>, unless there is an 'alt-fn
   property set on the function's symbol.   If such a function exists it is called
   instead.

   e.g.  
   CL-USER> (connect)
   CL-USER> (setf (get 'mysql-close 'alt-fn) (lambda (db)
                                               (print \"Closing! \")
                                               (libmysql-close db)))
   CL-USER> (disconnect)
   Closing!"
  (let* ((n name)
	 (int-name internal-name)
	 (int-libname (intern (string-upcase
			       (format nil "lib~A" int-name))))
	 (docstring (format nil "Library wrapper for MySQL function: ~A" name))
	 (mysql-doc-ref (format nil *mysql-dev-api-url* (string-downcase  int-name)))
	 (arg-names (mapcar #'car args)))
    (if *generate-alt-fns*
	`(progn  (defcfun (,n ,int-libname) ,return-type
		   ,mysql-doc-ref
		   ,@args)
		 (defun ,int-name ,arg-names
		   ,docstring
		   (let ((alt-fn (get ',int-name 'alt-fn)))
		     (if alt-fn
			 (funcall alt-fn ,@arg-names)
			 (,int-libname ,@arg-names)))))
	`(defcfun (,n ,int-name) ,return-type
	   ,mysql-doc-ref
	   ,@args))))
 
(defmysqlfun ("mysql_init" mysql-init) :pointer
  (mysql :pointer))

(defmysqlfun ("mysql_close" mysql-close) :pointer
  (mysql :pointer))

(defmysqlfun ("mysql_error" mysql-error) :string
  (mysql :pointer))

(defmysqlfun ("mysql_errno" mysql-errno) :unsigned-int
  (mysql :pointer))

(defmysqlfun ("mysql_real_connect" mysql-real-connect) :pointer
  (mysql :pointer)
  (host :string)
  (user :string)
  (password :string)
  (database :string)
  (port :int)
  (unix-socket :string)
  (client-flag :unsigned-long))

(defmysqlfun ("mysql_affected_rows" mysql-affected-rows) :unsigned-long-long
  (mysql :pointer))

(defmysqlfun ("mysql_character_set_name" mysql-character-set-name) :string
  (mysql :pointer))

(defmysqlfun ("mysql_ping" mysql-ping) :int
  (mysql :pointer))

(defmysqlfun ("mysql_query" mysql-query) :int
  (mysql :pointer)
  (statement :string))

(defmysqlfun ("mysql_real_escape_string" mysql-real-escape-string) :unsigned-long
  (mysql :pointer)
  (to    :string)
  (from  :string)
  (length :unsigned-int))

(defmysqlfun ("mysql_escape_string" mysql-escape-string) :unsigned-long
  (to    :string)
  (from  :string)
  (length :unsigned-int))

(defmysqlfun ("mysql_field_count" mysql-field-count) :unsigned-int
  (mysql :pointer))

(defmysqlfun ("mysql_get_client_version" mysql-get-client-version) :unsigned-long)

(defmysqlfun ("mysql_get_character_set_info" mysql-get-character-set-info) :void
  (mysql :pointer)
  (cs :pointer))

(defmysqlfun ("mysql_set_character_set" mysql-set-character-set) :int
  (mysql :pointer)
  (csname :string))

(defmysqlfun ("mysql_get_server_version" mysql-get-server-version) :unsigned-long
  (mysql :pointer))

(defmysqlfun ("mysql_select_db" mysql-select-db) :int
  (mysql :pointer)
  (db :string))

(defmysqlfun ("mysql_store_result" mysql-store-result) :pointer
  (mysql :pointer))

(defmysqlfun ("mysql_num_rows" mysql-num-rows) :unsigned-long-long
  (mysql-res :pointer))

(defmysqlfun ("mysql_list_dbs" mysql-list-dbs) :pointer
  (mysql :pointer)
  (wild :string))

(defmysqlfun ("mysql_list_tables" mysql-list-tables) :pointer
  (mysql :pointer)
  (wild :string))

(defmysqlfun ("mysql_list_fields" mysql-list-fields) :pointer
  (mysql :pointer)
  (table :string)
  (wild :string))

(defmysqlfun ("mysql_list_processes" mysql-list-processes) :pointer
  (mysql :pointer))

(defmysqlfun ("mysql_fetch_row" mysql-fetch-row) :pointer
  (mysql-res :pointer))

(defmysqlfun ("mysql_free_result" mysql-free-result) :void
  (mysql-res :pointer))

(defmysqlfun ("mysql_fetch_lengths" mysql-fetch-lengths) :pointer
  (mysql-res :pointer))

(defmysqlfun ("mysql_num_fields" mysql-num-fields) :unsigned-int
  (mysql-res :pointer))

(defmysqlfun ("mysql_next_result" mysql-next-result) :int
  (mysql :pointer))

(defmysqlfun ("mysql_fetch_fields" mysql-fetch-fields) :pointer
  (mysql-res :pointer))

(defmysqlfun ("mysql_options" mysql-options) :int
  (mysql :pointer)
  (option :int)
  (arg :pointer))

(defcenum enum-field-types
  :decimal :tiny :short :long :float :double :null :timestamp :longlong
  :int24 :date :time :datetime :year :newdate :varchar :bit
  (:newdecimal 246)
  (:enum 247)
  (:set 248)
  (:tiny-blob 249)
  (:medium-blob 250)
  (:long-blob 251)
  (:blob 252)
  (:var-string 253)
  (:string 254)
  (:geometry 255))

(defcenum enum-options
  :opt-connect-timeout :opt-compress :opt-named-pipe
  :init-command :read-default-file :read-default-group
  :set-charset-dir :set-charset-name :opt-local-infile
  :opt-protocol :shared-memory-base-name :opt-read-timeout
  :opt-write-timeout :opt-use-result
  :opt-use-remote-connection :opt-use-embedded-connection
  :opt-guess-connection :set-client-ip :secure-auth
  :report-data-truncation :opt-reconnect
  :opt-ssl-verify-server-cert)

(defcstruct mysql-field
  (name :string)
  (org-name :string)
  (table :string)
  (org-table :string)
  (db :string)
  (catalog :string)
  (def :string)
  (length :unsigned-long)
  (max-length :unsigned-long)
  (name-length :unsigned-int)
  (org-name-length :unsigned-int)
  (table-length :unsigned-int)
  (org-table-length :unsigned-int)
  (db-length :unsigned-int)
  (catalog-length :unsigned-int)
  (def-length :unsigned-int)
  (flags :unsigned-int)
  (decimals :unsigned-int)
  (charsetnr :unsigned-int)
  (type :int))

(defcstruct character-set
  (number :unsigned-int)
  (state :unsigned-int)
  (csname :string)
  (name :string)
  (comment :string)
  (dir :string)
  (mbminlen :unsigned-int)
  (mbmaxlen :unsigned-int))

;;; Decoders
;;;
(defun string-to-integer (string &optional len)
  (declare (optimize (speed 3) (safety 3))
	   (type (or null simple-string) string)
	   (type (or null (integer 0 128)) len))
  (when (and string (> (or len (length string)) 0))
    (parse-integer string :junk-allowed t)))

(defun string-to-float (string len)
  "Convert a MySQL float representation into a double.   Note that we could do better on DECIMAL/NUMERICs
   that have 0 places after the decimal."
  (declare (optimize (speed 3) (safety 3))
	   (type fixnum len)
	   (type (or null simple-string) string))
  (when (and string (> len 0))
    (let ((sign 1)
	  (integer-part 0)
	  (decimal-part 0)
	  (mantissa-part 0)
	  (decimal-length 1)
	  (mantissa-sign 1)
	  (passed-decimal nil)
	  (passed-mantissa nil))
      (declare (type integer integer-part decimal-part)
	       (type (integer 0 310) mantissa-part)
	       (type (integer -1 1) mantissa-sign sign)
	       (type (or null t) passed-decimal passed-mantissa))
      (loop for c across string
	 do (cond ((char= c #\+)
		   (if passed-mantissa
		       (setf mantissa-sign 1)
		       (setf sign 1)))
		  ((char= c #\-)
		   (if passed-mantissa
		       (setf mantissa-sign -1)
		       (setf sign -1)))
		  ((char= c #\.)
		   (setf passed-decimal t))
		  ((char= c #\e)
		   (setf passed-mantissa t))
		  (passed-mantissa
		   (setf mantissa-part
			 (+ (* mantissa-part 10)
			    (digit-char-p c))))
		  (passed-decimal
		   (setf decimal-part
			 (+ (* decimal-part 10)
			    (digit-char-p c))
			 decimal-length
			 (* 10 decimal-length)))
		  (t
		   (setf integer-part
			 (+ (* integer-part 10)
			    (digit-char-p c))))))
      (coerce (* sign (+ integer-part (/ decimal-part decimal-length)) (expt 10 (* mantissa-sign mantissa-part))) 'double-float))))

(defun string-to-ratio (string len)
  (when (and string (> (or len (length string)) 0))
    (let ((numerator 0)
	  (denominator 1)
	  (passed-decimal nil)
	  (sign 1))
      (declare (type integer numerator denominator))
      (loop for c across string
	 do (progn
	      (cond ((eq c #\.)
		     (setf passed-decimal t)t)
		    ((eq c #\-)
		     (setf sign (* -1 sign)))
		    (t
		     (when  passed-decimal
		       (setf denominator (* denominator 10)))
		     (setf numerator
			   (+ (digit-char-p c) (* numerator 10)))))))
      (* sign (/ numerator denominator)))))

(defun string-to-date (string &optional len)
  (declare (optimize (speed 3) (safety 3))
           (type (or null simple-string) string)
           (type (or null fixnum) len))
  (when (and string (> (or len (length string)) 9))
    (let ((y (parse-integer string :start 0 :end 4))
	  (m (parse-integer string :start 5 :end 7))
	  (d (parse-integer string :start 8 :end 10)))
      (encode-universal-time 0 0 0 d m y))))

(defun string-to-seconds (string &optional len)
  "Fairly ugly function to turn MySQL TIME duration into an integer representation.
   It's complicated because of ... well, read this:  http://dev.mysql.com/doc/refman/5.0/en/time.html"
  (declare (optimize (speed 3) (safety 3))
           (type (or null simple-string) string)
           (type (or null fixnum) len))
  (when string
    (let* ((strlen (or len (length string)))
	   (offset (- strlen 8)))
      (when (and (>= offset 0) (< offset 3))
	(let* ((start (if (eql #\- (elt string 0)) 1 0))
	       (h (parse-integer string :start start :end (+ 2 offset)))
	       (m (parse-integer string :start (+ 3 offset) :end (+ 5 offset)))
	       (s (parse-integer string :start (+ 6 offset) :end (+ 8 offset)))
	       (time (+ (* h 3600) (* m 60) s)))
	  (declare (type (integer 0 839) h)
		   (type (integer 0 59) m s))
	  (if (eql start 1)
	      (* -1 time)
	      time))))))

(defun string-to-universal-time (string &optional len)
  (declare (optimize (speed 3) (safety 3))
           (type (or null simple-string) string)
           (type (or null fixnum) len))
  (when (and string (> (or len (length string)) 0))
    (+ (string-to-date (subseq string 0 10))
       (string-to-seconds (subseq string 11)))))

(defparameter *type-map* (make-hash-table))

(eval-when (:load-toplevel)
  (mapcar (lambda (map)
	    (setf (gethash (first map) *type-map*) (second map)))
	  '((:DECIMAL  string-to-ratio)
	    (:TINY  string-to-integer)
	    (:SHORT  string-to-integer)
	    (:LONG  string-to-integer)
	    (:FLOAT  string-to-float)
	    (:DOUBLE  string-to-float)
	    (:NULL  (lambda (string)
		      (declare (ignore string))
		      nil))
	    (:TIMESTAMP  string-to-universal-time)
	    (:LONGLONG string-to-integer)
	    (:INT24  string-to-integer)
	    (:DATE  string-to-date)
	    (:TIME  string-to-seconds)
	    (:DATETIME  string-to-universal-time)
	    (:YEAR  string-to-integer)
	    (:NEWDATE  string-to-universal-time)
	    (:NEWDECIMAL  string-to-ratio))))

;;; Error handling
;;;
(define-condition mysql-error (error)
                  ((message :initarg :message :reader mysql-error-message)
		   (errno :initarg :errno :reader mysql-error-errno))
  (:report (lambda (condition stream)
             (format stream "MySQL error: \"~A\" (errno = ~D)."
                     (mysql-error-message condition)
		     (mysql-error-errno condition)))))

(define-condition cl-mysql-error (error)
                  ((message :initarg :message :reader cl-mysql-error-message))
  (:report (lambda (condition stream)
             (format stream "cl-mysql error: \"~A\""
                     (cl-mysql-error-message condition)))))

(defun error-if-non-zero (database return-value)
  (if (not (eql 0 return-value))
      (error 'mysql-error
	     :message (mysql-error database)
	     :errno (mysql-errno database)))
  return-value)

(defun error-if-null (database return-value)
  (if (null-pointer-p return-value)
      (error 'mysql-error 
	     :message (mysql-error database)
	     :error (mysql-errno database)))
  return-value)

;;; Connections
;;;
(defvar *connection-stack* nil)

(defun add-connection (mysql)
  "Adds a connection to the pool"
  (push mysql *connection-stack*))

(defun get-connection (&optional no-error)
  "Adds a connection to the pool"
  (cond ((or (null *connection-stack*)
	     (= 0 (length *connection-stack*)))
	 (if no-error
	     (values nil)
	     (error 'cl-mysql-error
		    :message "There are no connections established!")))
	(t (car *connection-stack*))))

(defun drop-connection ()
  (pop *connection-stack*))

(defmacro with-connection ((var &optional database) &body body)
  `(let ((,var (or ,database (get-connection))))
     ,@body))

;;; High level API
;;;
(defun use (name &key database)
  "Equivalent to running:
   CL-USER> (query \"USE <name>\")"
  (with-connection (conn database)
    (error-if-non-zero conn (mysql-select-db conn name))
    (values)))

(defun decode-version (int-version)
  "Return a list of version details <major> <release> <version>"
  (let* ((version (mod int-version 100))
	 (major-version (floor int-version 10000))
	 (release-level (mod (floor int-version 100) 10)))
    (list major-version release-level version)))

(defun client-version ()
  "Returns a three part list containing the decoded client version information"
  (decode-version (mysql-get-client-version)))

(defun server-version (&key database)
  "Returns a three part list containing the decoded server version information"
  (with-connection (conn database)
    (decode-version (mysql-get-server-version conn))))

(defun list-dbs (&key database)
  (with-connection (conn database)
    (let ((result (error-if-null conn (mysql-list-dbs conn (null-pointer)))))
      (process-result-set result *type-map* conn))))

(defun list-tables (&key database)
  (with-connection (conn database)
    (let ((result (error-if-null conn (mysql-list-tables conn (null-pointer)))))
      (process-result-set result *type-map* conn))))

(defun list-fields (table &key database)
  (with-connection (conn database)
    (let ((result (error-if-null conn (mysql-list-fields conn table (null-pointer)))))
      (process-result-set result *type-map* conn))))

(defun list-processes (&key database)
  (with-connection (conn database)
    (let ((result (error-if-null conn (mysql-list-processes conn))))
      (process-result-set result *type-map* conn))))

;;; String/Character set/Collation stuff
;;;
(defun escape-string (string &key database)
  "Given a string, encode it appropriately.   This function relies on the fact that
   the character set encoding was set to UTF-8 when the connection is made."
  (when string
    (with-connection (conn database)
      (with-foreign-string (from-string string)
	(let* ((from-length (cffi-utf8-length from-string))
	       (to-length (1+ (* from-length 2)))
	       (to-string (foreign-alloc :unsigned-char :count to-length))
	       (return-string nil))
	  (unwind-protect (progn
			    (mysql-real-escape-string conn to-string from-string from-length)
			    (setf return-string (foreign-string-to-lisp to-string)))
	    (foreign-free to-string))
	  (values return-string))))))

(defun cffi-utf8-length (cffi-string)
  "We need this function because mysql_real_escape_string requires the length
   of the from string in bytes (not characters)"
  (do ((i 0 (incf i)))
      ((eql 0 (mem-ref cffi-string :unsigned-char i)) i)))

(defun get-character-set-info (&key database)
  "Returns the character set information for the connection as a sequence:
      (collation name number state)"
  (with-connection (conn database)
    (with-foreign-object (charset 'character-set)
      (mysql-get-character-set-info conn charset)
      (list (foreign-slot-value charset 'character-set 'csname)
	    (foreign-slot-value charset 'character-set 'name)
	    (foreign-slot-value charset 'character-set 'number)
	    (foreign-slot-value charset 'character-set 'state)))))

(defun set-character-set (csname &key database)
  (with-connection (conn database)
    (error-if-non-zero database (mysql-set-character-set conn csname))))

;;; Result set functions
;;;
(defun field-names-and-types (mysql-res)
  "Retrieve from a MYSQL_RES a list of cons ((<field name> <field type>)*) "
  (let ((num-fields (1- (mysql-num-fields mysql-res)))
	(fields (mysql-fetch-fields mysql-res)))
    (loop for i from 0 to num-fields
       collect (let ((mref (mem-aref fields 'mysql-field i)))
		 (list
		  (foreign-slot-value mref 'mysql-field 'name)
		  (foreign-enum-keyword
		   'enum-field-types
		   (foreign-slot-value mref 'mysql-field 'type))
		  (foreign-slot-value mref 'mysql-field 'flags))))))

(defparameter *binary-types* #(:BIT :BINARY :VARBINARY :GEOMETRY))
(declaim (inline extract-field process-row))
(defun extract-field (row field-index field-length type-map field-detail)
  "Returns either a string or an unsigned byte array for known binary types. The
   designation of binary types per the C API seems a bit weird.   Basically,
   BIT, BINARY and VARBINARY are binary and so are BLOBs with the binary flag
   set.   It seems that other fields also have the binary flag set that are not
   binary and the BIT type, whilst binary doesn't have the flag set.   Bizarre-o."
  (destructuring-bind (field-name field-type field-flag) field-detail
    (declare (ignore field-name)
             (optimize (speed 3) (safety 3))
	     (type (integer 0 65536) field-index field-flag)
	     (type (integer 0 4294967296) field-length )
	     (type (simple-array symbol)  *binary-types*))
    (if (eql field-length 0)
	(return-from extract-field nil))
    (if (or (and (eq field-type :BLOB)
		 (logtest +field-binary+ field-flag))
	    (find field-type *binary-types*))
	(let ((arr (make-array field-length :element-type '(unsigned-byte 8)))
	      (ptr (mem-ref row :pointer field-index)))
	  (loop for i from 0 to (1- field-length)
	     do (setf (elt arr i) (mem-ref ptr :unsigned-char i)))
	  (values  arr))
	(let ((fn (gethash field-type type-map)))
	  (declare (type (or null symbol function) fn))
	  (values (if fn
		      (funcall fn (mem-ref row :string field-index) field-length)
		      (mem-ref row :string field-index)))))))

(defun process-row (mysql-res row num-fields field-names-and-types type-map)
  (declare (optimize (speed 3) (safety 3))
	   (type (integer 0 65536) num-fields))
  (let* ((mysql-lens (mysql-fetch-lengths mysql-res))
         (int-size (foreign-type-size :int)))
    (declare (type (integer 0 16) int-size))
    (loop for i of-type fixnum from 0 to (* num-fields int-size) by int-size
       for f of-type list in field-names-and-types
       collect (extract-field row i
			      (mem-ref mysql-lens :unsigned-long i) type-map f))))

(defun result-data (mysql-res type-map field-names-and-types)
  "Internal function that processes a result set and returns all the data.
   If field-names-and-types is NIL the raw (string) data is returned"
  (declare (optimize (speed 3))
	   (ftype (function (t t fixnum list (or t null)) list) process-row))
  (let ((num-fields (mysql-num-fields mysql-res)))
    (loop for row = (mysql-fetch-row mysql-res)
       until (null-pointer-p row)
       collect (process-row mysql-res row num-fields field-names-and-types type-map))))

(defun process-result-set (mysql-res type-map database)
  "Result set will be NULL if the command did not return any results.   In this case we return a cons
   the rows affected."
  (declare (optimize (speed 3)))
  (cond ((null-pointer-p mysql-res)
	 (cons (mysql-affected-rows (or database (get-connection))) nil))
	(t
	 (let ((fields (field-names-and-types mysql-res)))
					;(print fields)
	   (cons
	    (mapcar #'car fields)
	    (result-data mysql-res type-map fields))))))

(defun query (query &key (type-map *type-map*) database)
  "For a SELECT query or stored procedure that returns data, query will return 
   a list of result sets.   Each result set will have 1 or more sublists 
   where the first sublist contains the column names and the remaining lists 
   represent the rows of the result set.  If the query does not return a result
   set (for example if the query is an INSERT, UPDATE) the return value is the 
   number of rows affected.    Because cl-mysql supports multiple-statements 
   you can execute code like the following:

    CL-MYSQL-SYSTEM> (query \"CREATE TABLE a(a INT); 
                   INSERT INTO a (a) VALUES (1); DELETE FROM a; DROP TABLE a\")
    ((0) (1) (1) (0))</code></pre>

    The type-map, if set will alter the decoding into CL types.   If you set this to
    nil it will have the effect of disabling all CL type conversions and return
    either character or binary data only.   This might be useful for performance reasons, (cl-mysql 
    is much faster when it doesn't need to translate types) but it also might 
    be all you need.   Consider for instance if you're displaying a lot of 
    numerics on a web-page.    If you do not need to convert the data into
    floats/integers before displaying them on a page then raw could be useful 
    here too.  Finally, <strong>cl-mysql</strong> attempts to convert all 
    numeric types to their closest CL representation.   For very large numerics,
    or numerics that have very high precision this might not be what you want.
    In this case you could attempt to write your own conversion routine and 
    inject it into cl-mysql through the type-map."
  (with-connection (conn database)
    (error-if-non-zero conn (mysql-query conn query))
    (loop for result-set = (mysql-store-result conn)
       nconc (list (unwind-protect
			(process-result-set result-set (or type-map
							   (make-hash-table)) conn)))
       until (progn
	       (mysql-free-result result-set)
	       (not (eql 0 (mysql-next-result conn)))))))

(defun ping (&key database)
  "Check whether a connection is established or not.  If :opt-reconnect is 
   set and there is no connection then MySQL's C API attempts a reconnection."
  (with-connection (conn database)
    (error-if-non-zero conn (mysql-ping conn))
    (values t)))

(defun connect (&key host user password database port socket
		(client-flag (list +client-compress+
				   +client-multi-statements+
				   +client-multi-results+)))
  "Connect will present to MySQL sensible defaults for all the connection items.    
   The following code will attach you to a MySQL instance running on localhost, 
   as the current user with no password.   It will automatically turn on compression 
   between client-and-server and also enable multiple-result sets if possible.

   CL-USER> (connect)

   If unsuccesful connect will raise a SIMPLE-ERROR, otherwise it will place the 
   connection into a stack.   This value will be used in all subsequent operations 
   where the :database key argument is omitted."
  (let* ((mysql (mysql-init (null-pointer))))
    (error-if-null mysql (mysql-real-connect mysql
					     (or host "localhost")
					     (or user (null-pointer))
					     (or password (null-pointer))
					     (or database (null-pointer))
					     (or port 0)
					     (or socket (null-pointer))
					     (or (reduce #'logior (or client-flag '(0))))))
    ;; To ensure proper string decoding between CL & MySQL we better set the connection to be UTF-8 ...
    (add-connection mysql)
    (error-if-non-zero mysql (set-character-set "UTF8" :database mysql))
    (values mysql)))

(defun disconnect (&key database)
  "Unless database is supplied, disconnect will take the top element of the connection stack and close it."
  (with-connection (conn database)
    (mysql-close conn)
    (setf *connection-stack*
	  (remove-if (lambda (x)
		       (equalp conn x)) *connection-stack*))))

(defun %set-string-option (option value &key database)
  (let ((retval 0))
    (with-connection (conn database)
      (with-foreign-pointer-as-string (str 255)
	(setf retval (mysql-options conn
				    (foreign-enum-value 'enum-options option)
				    (lisp-string-to-foreign value str 255)))))
    (values retval)))

(defun %set-int-option (option value &key database)
  (let ((retval 0))
    (with-connection (conn database)
      (with-foreign-object (int-value :int)
	(setf (mem-ref int-value :int) value)
	(setf retval (mysql-options conn
				    (foreign-enum-value 'enum-options option)
				    int-value))))
    (values retval)))

(defun option (option value &key database)
  "Use this to set a client specific connection option.
   CL-USER> (option :opt-reconnect 1)"
  (typecase value
    (string (%set-string-option option value :database database))
    (null   (%set-int-option option 0 :database database))
    (t      (%set-int-option option value :database database))))

    