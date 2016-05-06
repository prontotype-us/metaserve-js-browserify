fs = require 'fs'
browserify = require 'browserify'
React = require 'react'
Compiler = require 'metaserve/lib/compiler'

VERBOSE = process.env.METASERVE_VERBOSE?

class BrowserifyCompiler extends Compiler

    default_options:
        base_dir: './static/js'
        ext: 'js'

    compile: (coffee_filename) ->
        options = @options
        return (req, res, next) =>

            try
                console.log '[Browserify compiler] Going to compile ' + coffee_filename if VERBOSE
                bundler = browserify(options.browserify)
                @beforeBundle? bundler
                bundling = bundler.add(coffee_filename).bundle()
                bundling.on 'error', (err) ->
                    console.log '[Browserify compile error]', err
                    res.end "console.log('[Browserify compile error]', #{JSON.stringify err.toString()})"
                bundling.pipe(res)

            catch e
                console.log '[Browserify compile error]', err
                res.send 500, e.toString()

module.exports = (options={}) -> new BrowserifyCompiler(options)
module.exports.BrowserifyCompiler = BrowserifyCompiler

