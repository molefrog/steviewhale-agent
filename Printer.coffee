cups = require "cupsidity"
_    = require "lodash"
Q    = require "q"

###
# Class Printer represents high-level interface for printing 
# using specific printer destination
###
class Printer 
	constructor : (@destination) ->
		@jobs = {}

		@state  = 0
		@reason = "none"

	###
	# Cancels all printer jobs	
	###
	cancelAll : ->
		jobs = cups.getJobs
			dest  : @destination
			which : "active"

		_.each jobs, (job) =>
			cups.cancelJob
				dest  : @destination
				id    : job.id

	###
	# Prints file. Returns deferred object.
	###
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

		@jobs[jobId] = 
			id    : jobId 
			defer : deferred	
			state : "none"

		deferred.promise

	###
	# This function is used to check whether printer or job 
	# status has changed
	### 
	stateCheckRoutine : ->
		dests = do cups.getDests
		
		idx = _.findIndex dests, (dest) => 
			dest.name == @destination
	
		return if idx == -1

		dest = dests[ idx ]

		reason = dest.options['printer-state-reasons']
		state  = dest.options['printer-state']

		stateChanged  = (state  != @state)
		reasonChanged = (reason != @reason)

		if stateChanged
			console.log "State changed #{@state} -> #{state}"
			@state = state

		if reasonChanged
			console.log "Reason changed #{@reason} -> #{reason}"
			@reason = reason
			
			if @reason != 'none'
				do @cancelAll

		cupsJobs = cups.getJobs
			dest : @destination

		_.each @jobs, (job) =>
			idx = _.findIndex cupsJobs, (j) -> j.id == job.id
			return if idx == -1

			cupsJob = cupsJobs[ idx ]

			if cupsJob.state != job.state
				console.log "Job ##{job.id} state changed #{job.state} -> #{cupsJob.state}"
				job.state = cupsJob.state

				switch job.state
					when "completed"
						do job.defer.resolve
						delete @jobs[ job.id ]

					when "cancelled"
						do job.defer.reject
						delete @jobs[ job.id ]

					when "stopped", "aborted"
						cups.cancelJob
							dest : @destination
							id : job.id


	###
	# Function enables state change check 
	###
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

