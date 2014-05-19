path = require('path')
fs = require('fs')
Q = require('q')

fsExists = (path) ->
  d = Q.defer()
  fs.exists path, (exists) ->
    d.resolve(exists)
  d.promise

module.exports = (BasePlugin) ->
  class GenerationMessagePlugin extends BasePlugin

    name: 'generationmessage'

    config:
      generationMessagePath: '503-generation.html'

    serverExtend: (opts, next) ->
      {server} = opts
      plugin = @
      docpad = @docpad
      config = plugin.getConfig()

      lookInDirectory = (dir) ->
        if Array.isArray(dir)
          return (prev) ->
            dir.map(lookInDirectory).reduce(Q.when, Q(prev))
        (prev) ->
          return prev if prev?
          p = path.resolve(dir, config.generationMessagePath)
          fsExists(path.resolve(dir, config.generationMessagePath))
          .then (exists) ->
              return p if exists

      # A series of checks to see if the generation message file exists.
      Q()
      .then(lookInDirectory(docpad.getConfig().rootPath))
      .then(lookInDirectory(docpad.getConfig().srcPath))
      .then(lookInDirectory(docpad.getConfig().filesPaths))
      .then(lookInDirectory(docpad.getConfig().documentsPaths))
      .then (generationMessagePath) ->
        # Do a check if we have successfully found a generation message file.
        if !generationMessagePath?
          next()
          return

        # Finally, attach the Express middleware.
        server.use (req, res, expressNext) ->
          # Check if the website is being generated.
          if docpad.generated is false
            # Create a model without adding it to the database.
            file = docpad.createModel({fullPath: generationMessagePath})
            # Load the file.
            Q.ninvoke(file, 'load')
            .then ->
                # Render the file
                Q.ninvoke(file, 'render')
            .done (result) ->
                [content] = result
                # Send the rendered file.
                res.status(503)
                res.send(content)
            , (reason) ->
                expressNext(reason)
            return
          # Pass to the next middleware.
          expressNext()
          return

        next()
        return
      .done()

      @
