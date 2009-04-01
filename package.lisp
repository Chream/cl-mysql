;; $Id$
;;
(defpackage com.hackinghat.cl-mysql
  (:use :cl)
  (:nicknames "CL-MYSQL")
  (:shadowing-import-from "CL-MYSQL-SYSTEM"
	  #:connect #:query #:use #:disconnect #:ping #:option
	  #:client-version #:server-version
	  #:list-dbs #:list-tables #:list-processes #:list-fields
	  #:opt-connect-timeout #:opt-compress #:opt-named-pipe
	  #:init-command #:read-default-file #:read-default-group
	  #:set-charset-dir #:set-charset-name #:opt-local-infile
	  #:opt-protocol #:shared-memory-base-name #:opt-read-timeout
	  #:opt-write-timeout #:opt-use-result
	  #:opt-use-remote-connection #:opt-use-embedded-connection
	  #:opt-guess-connection #:set-client-ip #:secure-auth
	  #:report-data-truncation #:opt-reconnect
	  #:opt-ssl-verify-server-cert)
  (:export #:connect #:query #:use #:disconnect #:ping #:option
	   #:client-version #:server-version
	   #:list-dbs #:list-tables #:list-processes #:list-fields
	   #:opt-connect-timeout #:opt-compress #:opt-named-pipe
	   #:init-command #:read-default-file #:read-default-group
	   #:set-charset-dir #:set-charset-name #:opt-local-infile
	   #:opt-protocol #:shared-memory-base-name #:opt-read-timeout
	   #:opt-write-timeout #:opt-use-result
	   #:opt-use-remote-connection #:opt-use-embedded-connection
	   #:opt-guess-connection #:set-client-ip #:secure-auth
	   #:report-data-truncation #:opt-reconnect
	   #:opt-ssl-verify-server-cert))

