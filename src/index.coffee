fs = require 'fs'
browserify = require 'browserify'
React = require 'react'
Compiler = require 'metaserve/lib/compiler'

VERBOSE = process.env.METASERVE_VERBOSE?

class BrowserifyCompiler extends Compiler

    default_options:
        base_dir: './static/js'
        ext: 'js'

    compile: (coffee_filename, cb) ->
        options = @options

        if options.globals
            options.browserify.insertGlobalVars = {}
            for global_key, global_value of options.globals
                options.browserify.insertGlobalVars[global_key] = -> JSON.stringify global_value
            delete options.globals

        try
            console.log '[Browserify compiler] Going to compile ' + coffee_filename if VERBOSE
            bundler = browserify(options.browserify)
            @beforeBundle? bundler
            bundling = bundler.add(coffee_filename).bundle()
            bundling.on 'error', (err) ->
                console.log '[Browserify compile error]', err.toString()
                cb "[Browserify compile error] #{err.toString()}"

            compiled = ''
            bundling.on 'data', (data) ->
                compiled += data
            bundling.on 'end', ->
                cb null, {compiled}

        catch err
            console.log '[Browserify compile error]', err.toString()
            cb "[Browserify compile error] #{err.toString()}"

module.exports = (options={}) -> new BrowserifyCompiler(options)
module.exports.BrowserifyCompiler = BrowserifyCompiler

