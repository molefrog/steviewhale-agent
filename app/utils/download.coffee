request = require "request"
fs      = require "fs"
Q       = require "q"

module.exports = (uri, filename) ->
	deferred = do Q.defer

	stream = fs.createWriteStream filename 
	
	r = request(uri).pipe( stream )
	r.once "close", -> do deferred.resolve
	r.once "error", -> do deferred.reject

	deferred.promise
	