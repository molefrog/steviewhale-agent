cups = require "cupsidity"
_    = require "lodash"
Q    = require "q"

{ EventEmitter } = require "events" 
config = require "./utils/config"

###
# Class Printer represents high-level interface for printing 
# using specific printer destination
###
module.exports = class Printer extends EventEmitter
	constructor : (@destination) ->
		@jobs = {}

		@state  = @stateName 0
		@reason = "none"

	###
	# This function converts printer state code to human-readable
	# state string 
	###
	stateName : (number) ->
		switch number
			when 3 then "idle"
			when 4 then "processing"
			when 5 then "stopped"
			else "unknown"

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
			deferred.reject "cups.printFile returned 0"
			return deferred.promise

		@jobs[jobId] = 
			id    : jobId 
			defer : deferred	
			state : "none"

		setTimeout =>
			cups.cancelJob
				dest : @destination
				id : jobId
		, config.get("printer:printTimeout")

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
		state  = @stateName parseInt dest.options['printer-state']

		stateChanged  = (state  != @state)
		reasonChanged = (reason != @reason)

		if stateChanged
			@emit "state-changed", @state, state
			@state = state

		if reasonChanged
			@emit "reason-changed", @reason, reason
			@reason = reason
			
			# This method doesn't work properly!	
			# if @reason != 'none'
			# 	do @cancelAll

		cupsJobs = cups.getJobs
			dest : @destination

		_.each @jobs, (job) =>
			idx = _.findIndex cupsJobs, (j) -> j.id == job.id
			return if idx == -1

			cupsJob = cupsJobs[ idx ]

			if cupsJob.state != job.state
				@emit "job-state-changed", job, job.state, cupsJob.state
				job.state = cupsJob.state

				switch job.state
					when "completed"
						do job.defer.resolve
						delete @jobs[ job.id ]

					when "cancelled"
						job.defer.reject "Job #{job.id} cancelled"
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


