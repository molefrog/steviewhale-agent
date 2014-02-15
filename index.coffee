log     = require "./app/utils/log"
config  = require "./app/utils/config"
Printer = require "./app/Printer"

crypto  = require "crypto"
io      = require "socket.io-client"


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
	address = config.get "pool:address"
	timeout = config.get "pool:timeout"
	name    = config.get "pool:name"
	secret  = config.get "pool:secret" 

	log.info "Trying to connect to #{address}"
	socket = io.connect address,
		transports : [ "websocket" ]
	
	socket.on "connect", ->
		log.info "Connected. Trying to authorize as ##{name}"

	socket.on "handshake", (random, cb) ->
		log.info "Got random #{random}. Sending answer back."
		cb name, hashing(random, secret)

	socket.on "handshake-success", ->
		log.info "Authorization as ##{name} passed!"

	socket.on "disconnect", ->
		log.warn "Disconnected from #{address}"

	socket.on "error", ->
		log.warn "Connection problems. Will try againg in #{timeout}ms"
		setTimeout tryConnect, timeout

	# TODO:
	socket.on "print", (url, cb) ->


do tryConnect


