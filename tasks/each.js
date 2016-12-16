var async = require('async');
var fs = require('fs-extra');
var pluralize = require('pluralize');

module.exports = function(grunt) {
  grunt.registerMultiTask('each', require('../package').description, function() {
    var done = this.async();
    var options = this.options({ actions: [] });
    if (!Array.isArray(options.actions)) {
      options.actions = [options.actions];
    }
    options.actions.forEach(function(action, i) {
      if (typeof action === 'string') {
        options.actions[i] = require(action);
      }
    });

    var processed = 0;

    var perform = function(filepath, contents, cb) {
      async.reduce(options.actions, contents, function(memo, action, next) {
        var file = {
          path: filepath,
          contents: memo,
          origContents: contents
        };
        if (action.length === 1) {
          try {
            next(null, action(file));
          } catch (e) {
            next(e);
          }
        } else {
          action(file, next);
        }
      }, cb);
    };

    var write = function(dest, cb, err, contents) {
      if (err) {
        cb(err);
      } else if (dest) {
        processed++;
        fs.outputFile(dest, contents, { encoding: 'utf8' }, cb);
      } else {
        processed++;
        cb();
      }
    };

    async.each(this.files, function(file, next) {
      async.filter(file.src, function(filepath, cb) {
        fs.access(filepath, function(err) {
          cb(null, !err);
        });
      }, function(err, results) {
        async.reduce(results, {}, function(memo, filepath, cb) {
          fs.readFile(filepath, { encoding: 'utf8' }, function(err, contents) {
            if (err) {
              cb(err);
            } else {
              perform(filepath, contents, write.bind(this, file.dest, cb));
            }
          });
        }, next);
      });
    }, function(err) {
      if (err) {
        grunt.fail.fatal(err);
      } else {
        grunt.log.ok(processed + ' ' + pluralize('files', processed) + ' processed');
      }
      done();
    });
  });
};
