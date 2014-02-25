log      = require "./app/utils/log"
config   = require "./app/utils/config"
Printer  = require "./app/Printer"
download = require "./app/utils/download"
render   = require "./app/render"

crypto  = require "crypto"
io      = require "socket.io-client"
uid	    = require "uid"
path    = require "path"
fs      = require "fs"

###
# Initializing printer
###
printer = new Printer config.get "printer:name"
log.info "Selected printer #{config.get 'printer:name'}"

printer.on "state-changed", (from, to)->
	log.info "Printer state #{from} => #{to}"

printer.on "reason-changed", (from, to)->
	log.info "Printer reason #{from} => #{to}"

printer.on "job-state-changed", (job, from, to)->
	log.info "Job ##{job.id} state #{from} => #{to}"

do printer.cancelAll
do printer.startCheck


# Hashing algorithm that is used for authorization
hashing = (random, secret) ->
	hash = crypto.createHash "md5"
	hash.update(random + secret).digest "hex"

tryConnect = ->
	address  = config.get "pool:address"
	timeout  = config.get "pool:timeout"
	name     = config.get "pool:name"
	secret   = config.get "pool:secret" 

	log.info "Trying to connect to #{address}"
	socket = io.connect address,
		transports : [ "websocket" ]
		# This option is important when the very first
		# connect has failed
		"force new connection" : true
		
		# We implement our own reconnection algorithm
		"reconnect" : false
	
	attempt = 0
	socket.on "connect", ->
		attempt = 0
		log.info "Connected. Trying to authorize as ##{name}"

	socket.on "handshake", (random, cb) ->
		log.info "Got random #{random}. Sending answer back."
		cb name, hashing(random, secret)

	socket.on "handshake-success", ->
		log.info "Authorization as ##{name} passed!"

	socket.on "disconnect", ->
		log.warn "Disconnected from #{address}. Will try againg in #{timeout}ms"
		setTimeout tryConnect, timeout

	socket.on "error", ->
		log.warn "Connection problems."
		do socket.disconnect

	socket.on "print", (url, cb) ->
		filename = "#{__dirname}/#{uid 24}.jpg"

		log.info "Got printer job from the server #{url}"

		# TODO: handle promise errors 
		download(url, filename)
			.then ->
				log.info "File saved to #{filename}"

				render(filename)
			.then (rendered) ->
				printPath = path.resolve rendered
				log.info "File rendered to #{printPath}"

				printer.print(printPath, config.get "printer:options")
				.fin ->
					log.info "Removed temporary file #{rendered}"
					fs.unlink rendered
			.then ->
				log.info "Job successfully printed"
				cb null

			.fail (err) ->
				log.warn "Printing error: #{err}"
				cb "Printing error"
			.fin ->
				log.info "Removed temporary file #{filename}"
				fs.unlink filename
				
do tryConnect


