io = require "socket.io-client"


socket = io.connect "http://localhost:3030"
 

socket.on "connect", ->
	console.log "connected"