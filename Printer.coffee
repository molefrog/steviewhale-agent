cups = require "cupsidity"
_    = require "lodash"
Q    = require "q"

###
# Class Printer represents high-level interface for printing using specific 
# printer destination
###
class Printer 
	constructor : (@destination) ->
		@jobsDefer = {}

		@state =
			number : 0
			reason : "none"


	cancelAll : ->
		jobs = cups.getJobs
			dest  : @destination
			which : "active"

		_.each jobs, (job) =>
			cups.cancelJob
				dest : @destination
				id   : job.id


	print : (filename, options) ->
		deferred = do Q.defer

		jobId = cups.printFile 
			dest     : @destination
			title    : filename
			filename : filename
			options  : options

		if jobId == 0
			do deferred.reject
			return deferred.promise

		@jobsDefer[jobId] = 
			id    : jobId 
			defer : deferred	

		deferred.promise



	stateCheckRoutine : ->
		dests = cups.getDests()
		
		idx = _.findIndex dests, (dest) => dest.name == @destination
		return if idx == -1

		dest = dests[ idx ]

		reason = dest.options['printer-state-reasons']
		number = dest.options['printer-state']

		stateChanged  = (number != @state.number)
		reasonChanged = (reason != @state.reason)

		if stateChanged or reasonChanged
			console.log "State changed #{@state.number} -> #{number} | #{@state.reason} -> #{reason}"
			
			if reasonChanged and reason != 'none'
				console.log "Something went wrong!"
				do @cancelAll

				_.each @jobsDefer, (job) => 
					do job.defer.reject
					delete @jobsDefer[ job.id ] 

			@state.reason = reason
			@state.number = number

	startCheck : (interval = 1000) ->
		@intervalId = setInterval =>
			do @stateCheckRoutine
		, interval

	stopCheck : ->
		clearInterval @intervalId if @intervalId?



####
# Usage
####
filename = "1.jpg"
destination = "Canon_CP800"
options = 
	media : "Postcard(4x6in)"

printer = new Printer destination

do printer.cancelAll
do printer.startCheck

printer.print(filename, options)
.then ->
	console.log "# Job done!"
.fail ->
	console.log "# Job failed!"



