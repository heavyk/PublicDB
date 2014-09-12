(->
	'use strict'
	(require 'console').log '%s', 'tearing down app ' + applicationContext.name
	f = require 'org/arangodb/foxx/authentication'
	users = new f.Users applicationContext
	users.teardown!
	sessions = new f.Sessions applicationContext
	sessions.teardown!
)!