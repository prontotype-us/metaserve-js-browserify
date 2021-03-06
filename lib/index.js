// Generated by CoffeeScript 1.12.7
(function() {
  var VERBOSE, browserify, fs;

  fs = require('fs');

  browserify = require('browserify');

  VERBOSE = process.env.METASERVE_VERBOSE != null;

  module.exports = {
    ext: 'js',
    default_config: {
      content_type: 'application/javascript'
    },
    compile: function(filename, config, context, cb) {
      var browserify_config, bundler, bundling, compiled, err;
      if (VERBOSE) {
        console.log('[BrowserifyCompiler.compile]', filename, config);
      }
      browserify_config = Object.assign({}, config.browserify);
      if ((context != null) && Object.keys(context).length) {
        browserify_config.insertGlobalVars = {};
        Object.keys(context).map(function(global_key) {
          var global_value;
          global_value = context[global_key];
          return browserify_config.insertGlobalVars[global_key] = function() {
            return JSON.stringify(global_value);
          };
        });
      }
      try {
        if (VERBOSE) {
          console.log('[Browserify compiler] Going to compile ' + filename, config);
        }
        bundler = browserify(browserify_config);
        if (typeof config.beforeBundle === "function") {
          config.beforeBundle(bundler);
        }
        bundling = bundler.add(filename).bundle();
        bundling.on('error', function(err) {
          console.error('[Browserify compile error]', err.toString(), err.stack);
          return cb("[Browserify compile error] " + (err.toString()));
        });
        compiled = '';
        bundling.on('data', function(data) {
          return compiled += data;
        });
        return bundling.on('end', function() {
          return cb(null, {
            content_type: config.content_type,
            compiled: compiled
          });
        });
      } catch (error) {
        err = error;
        console.error('[Browserify compile error]', err.toString());
        return cb("[Browserify compile error] " + (err.toString()));
      }
    }
  };

}).call(this);
