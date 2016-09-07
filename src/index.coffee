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

        try
            console.log '[Browserify compiler] Going to compile ' + coffee_filename if VERBOSE
            bundler = browserify(options.browserify)
            @beforeBundle? bundler
            bundling = bundler.add(coffee_filename).bundle()
            bundling.on 'error', (err) ->
                console.log '[Browserify compile error]', err
                cb "[Browserify compile error] #{err}"

            compiled = ''
            bundling.on 'data', (data) ->
                compiled += data
            bundling.on 'end', ->
                cb null, {compiled}

        catch e
            console.log '[Browserify compile error]', err
            cb "[Browserify compile error] #{err}"

module.exports = (options={}) -> new BrowserifyCompiler(options)
module.exports.BrowserifyCompiler = BrowserifyCompiler

