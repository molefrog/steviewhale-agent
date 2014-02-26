Canvas = require "canvas"
fs     = require "fs"
Q      = require "Q"
uid    = require "uid"
path   = require "path"

templateFilename = path.resolve "#{__dirname}/template.png"
marginFraction = 0.065


module.exports = (filename) ->
	deferred = do Q.defer

	fs.readFile templateFilename, (err, templateBuffer) ->
		if err
			console.log err
			return deferred.reject "Error reading template file #{err}"


		img = new Canvas.Image
		img.src = templateBuffer

		canvas = new Canvas img.width, img.height
		ctx = canvas.getContext "2d"

		fs.readFile filename, (err, sourceBuffer) ->
			if err
				console.log err
				return deferred.reject "Error reading source file #{err}"


			source = new Canvas.Image
			source.src = sourceBuffer

			margin = img.width * marginFraction
			w = img.width - 2 * margin

			ctx.drawImage img, 0, 0, img.width, img.height
			ctx.drawImage source, margin, margin, w, w


			outFilename = "#{uid 24}.png"
			out = fs.createWriteStream outFilename
			stream = canvas.pngStream()

			r = stream.pipe out

			r.on "close", ->
				deferred.resolve outFilename

	deferred.promise
