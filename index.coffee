# io = require "socket.io-client"

# hashing = (random, secret) ->
# 	(require "crypto").createHash('md5').update(random + secret).digest('hex')


# name   = ""
# secret = "" 

# socket = io.connect "http://localhost:8080/pool"
 



# ####
# # Usage
# ####
# filename = "1.jpg"
# destination = "Canon_CP800"
# options = 
# 	media : "Postcard(4x6in)"

# printer = new Printer destination

# printer.on "state-changed", (from, to)->
# 	console.log "State #{from} => #{to}"

# printer.on "reason-changed", (from, to)->
# 	console.log "Reason #{from} => #{to}"

# printer.on "job-state-changed", (job, from, to)->
# 	console.log "Jon ##{job.id} #{from} => #{to}"

# do printer.cancelAll
# do printer.startCheck

# printer.print(filename, options)
# .then ->
# 	console.log "# Job done!"
# .fail ->
# 	console.log "# Job failed!"


# socket.on "connect", ->
# 	console.log "connected"


# 	socket.once "handshake", (random, cb) ->
# 		cb name, hashing(random, secret)

# 	socket.once "handshake-success", ->
# 		console.log "Fuck yeah!"


# socket.on "disconnect", ->
# 	console.log "disconnected"