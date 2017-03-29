fs = require 'fs'
browserify = require 'browserify'

VERBOSE = process.env.METASERVE_VERBOSE?

module.exports =
    ext: 'js'

    default_config:
        content_type: 'application/javascript'

    compile: (filename, config, context, cb) ->
        console.log '[BrowserifyCompiler.compile]', filename, config if VERBOSE
        browserify_config = Object.assign {}, config.browserify

        # Use browserify insertGlobalVars for context
        if context? and Object.keys(context).length
            browserify_config.insertGlobalVars = {}
            Object.keys(context).map (global_key) ->
                global_value = context[global_key]
                browserify_config.insertGlobalVars[global_key] = -> JSON.stringify global_value

        try
            console.log '[Browserify compiler] Going to compile ' + filename, config if VERBOSE

            # Configure browerify and transforms

            bundler = browserify(browserify_config)

            config.beforeBundle? bundler

            if config.uglify
                process.env.NODE_ENV = 'production' # For React
                bundler = bundler.transform {global: true}, 'uglifyify'

            # Do bundling

            bundling = bundler.add(filename).bundle()
            bundling.on 'error', (err) ->
                console.error '[Browserify compile error]', err.toString()
                cb "[Browserify compile error] #{err.toString()}"

            compiled = ''
            bundling.on 'data', (data) ->
                compiled += data

            # Finished bundling

            bundling.on 'end', ->
                cb null, {
                    content_type: config.content_type
                    compiled
                }

        catch err
            console.error '[Browserify compile error]', err.toString()
            cb "[Browserify compile error] #{err.toString()}"

