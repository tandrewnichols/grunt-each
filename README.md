[![Build Status](https://travis-ci.org/tandrewnichols/grunt-each.png)](https://travis-ci.org/tandrewnichols/grunt-each) [![downloads](http://img.shields.io/npm/dm/grunt-each.svg)](https://npmjs.org/package/grunt-each) [![npm](http://img.shields.io/npm/v/grunt-each.svg)](https://npmjs.org/package/grunt-each) [![Code Climate](https://codeclimate.com/github/tandrewnichols/grunt-each/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/grunt-each) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/grunt-each/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/grunt-each) [![dependencies](https://david-dm.org/tandrewnichols/grunt-each.png)](https://david-dm.org/tandrewnichols/grunt-each)

# grunt-each

A grunt plugin to perform actions on a list of files.

## Getting Started

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```bash
npm install grunt-each --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```javascript
grunt.loadNpmTasks('grunt-each');
```

Alternatively, install [task-master](http://github.com/tandrewnichols/task-master) and let it manage this for you.

## The "each" task

### Overview

In your project's Gruntfile, add a section named `each` to the data object passed into `grunt.initConfig()`. The `each` task is a multitask. For each target you define, specify a list of files in any of the normal grunt formats, and under options, add an `actions` property. This can be a function, a string (corresponding a to a module to require), or an array combining functions and strings. If an action is a string, `grunt-each` will attempt to require a module with that name and use that as the action. This allows actions to be published for reuse or to be abstracted to separate files when they are long or require testing or are used elsewhere in the codebase. Functions (or modules referenced by string) can be either sync or async. Synchronous actions are passed a file object with properties `name`, `contents`, and `origContents` and should return the modified contents. Asynchronous actions are passed the same file object, as well as a callback which accepts an optional error and the modified contents. Actions are composed in reverse, so that the `contents` property of the file in the second action will be the return value (or callback value) of the first action.

### Examples

```js
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-each');

  grunt.initConfig({
    each: {
      // Single function
      split: {
        src: 'src/**/*.txt',
        dest: 'dest/',
        options: {
          // Synchronous action signature
          actions: function(file) {
            return file.contents.split(' ')[1]; 
          }
        }
      },
      // Single string
      splitString: {
        src: 'src/**/*.txt',
        dest: 'dest/'
        options: {
          actions: './actions/split'
        }
      },
      // Array combining these
      reverse: {
        src: 'src/**/*.txt',
        dest: 'dest/'
        options: {
          actions: ['./actions/split', function(file) {
            // Assuming ./actions/split does the same thing as the action in
            // each.split, the output of this composition will be the second
            // word in the file reversed.
            return file.contents.split('').reverse().join('');
          }]
        }
      },
      async: {
        src: 'src/**/*.txt',
        dest: 'dest/'
        options: {
          // Asynchronous action signature
          actions: [function(file, cb) {
            doSomethingAsync(file.contents, function(newStuff) {
              cb(null, newStuff);
            });
          }]
        }
      }
    }
  });
};
```

See the tests for extensive examples.

## Contributing

Please see [the contribution guidelines](CONTRIBUTING.md).
