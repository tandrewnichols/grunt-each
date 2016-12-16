sinon = require 'sinon'
proxyquire = require 'proxyquire'

describe 'each', ->
  Given -> @fs =
    access: sinon.stub()
    readFile: sinon.stub()
    outputFile: sinon.stub()

  Given -> @banana = (file) ->
    return file.contents.split(' ')[1]
  Given -> @apple = (file, cb) ->
    cb(null, file.contents.split(' ')[1])

  Given -> @plantain = (file) ->
    return file.contents.split('').reverse().join('')
  Given -> @pineapple = (file, cb) ->
    cb(null, file.contents.split('').reverse().join(''))

  Given -> @subject = proxyquire.noCallThru() '../tasks/each',
    'fs-extra': @fs
    banana: @banana
    plantain: @plantain
    apple: @apple
    pineapple: @pineapple

  context 'happy path cases (no errors)', ->
    Given -> @fs.access.withArgs('foo', sinon.match.func).callsArgWith(1, null)
    Given -> @fs.readFile.withArgs('foo', { encoding: 'utf8' }, sinon.match.func).callsArgWith(2, null, 'foo contents')
    Given -> @context =
      files: [
        src: ['foo']
        dest: 'bar'
      ]
    Given -> @grunt =
      registerMultiTask: (name, desc, fn) => fn.call(@context)
      fail:
        fatal: sinon.stub()
      log:
        ok: sinon.stub()

    context 'no actions', ->
      Given -> @fs.outputFile.withArgs('bar', 'foo contents', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)
      When (done) ->
        @context.options = (opts) -> opts
        @context.async = -> done
        @subject(@grunt)
      Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

    context '1 sync action', ->
      Given -> @fs.outputFile.withArgs('bar', 'contents', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)

      context 'as function', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = (file) ->
              return file.contents.split(' ')[1]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'as string', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = 'banana'
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'as function in array', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [(file) ->
              return file.contents.split(' ')[1]
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'as string in array', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = ['banana']
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

    context '1 async action', ->
      Given -> @fs.outputFile.withArgs('bar', 'contents', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)

      context 'as function', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = (file, cb) ->
              cb(null, file.contents.split(' ')[1])
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'as string', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = 'apple'
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'as function in array', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [(file, cb) ->
              cb(null, file.contents.split(' ')[1])
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'as string in array', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = ['apple']
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

    context 'multiple sync actions', ->
      Given -> @fs.outputFile.withArgs('bar', 'stnetnoc', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)

      context 'as functions', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [
              (file) ->
                return file.contents.split(' ')[1]
            ,
              (file) ->
                return file.contents.split('').reverse().join('')
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'as strings', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = ['banana', 'plantain']
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

    context 'multiple async actions', ->
      Given -> @fs.outputFile.withArgs('bar', 'stnetnoc', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)

      context 'as functions', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [
              (file, cb) ->
                cb(null, file.contents.split(' ')[1])
            ,
              (file, cb) ->
                cb(null, file.contents.split('').reverse().join(''))
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'as strings', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = ['apple', 'pineapple']
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

    context 'sync and async', ->
      Given -> @fs.outputFile.withArgs('bar', 'stnetnoc', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)

      context 'two functions', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [
              (file) ->
                return file.contents.split(' ')[1]
            ,
              (file, cb) ->
                cb(null, file.contents.split('').reverse().join(''))
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'two strings', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = ['banana', 'pineapple']
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'a function and a string', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [
              (file) ->
                return file.contents.split(' ')[1]
            ,
              'pineapple'
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'a string and a function', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [
              'banana'
            ,
              (file, cb) ->
                cb(null, file.contents.split('').reverse().join(''))
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

    context 'async and sync', ->
      Given -> @fs.outputFile.withArgs('bar', 'stnetnoc', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)

      context 'two functions', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [
              (file, cb) ->
                cb(null, file.contents.split(' ')[1])
            ,
              (file) ->
                return file.contents.split('').reverse().join('')
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'two strings', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = ['apple', 'plantain']
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'a function and a string', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [
              (file, cb) ->
                cb(null, file.contents.split(' ')[1])
            ,
              'plantain'
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

      context 'a string and a function', ->
        When (done) ->
          @context.options = (opts) ->
            opts.actions = [
              'apple'
            ,
              (file) ->
                return file.contents.split('').reverse().join('')
            ]
            opts
          @context.async = -> done
          @subject(@grunt)
        Then -> @grunt.log.ok.should.have.been.calledWith '1 file processed'

    context 'multiple files', ->
      Given -> @context.files.push
        src: ['baz', 'quux']
        dest: 'blah'
      Given -> @fs.access.withArgs('baz', sinon.match.func).callsArgWith(1, null)
      Given -> @fs.readFile.withArgs('baz', { encoding: 'utf8' }, sinon.match.func).callsArgWith(2, null, 'baz contents')
      Given -> @fs.access.withArgs('quux', sinon.match.func).callsArgWith(1, null)
      Given -> @fs.readFile.withArgs('quux', { encoding: 'utf8' }, sinon.match.func).callsArgWith(2, null, 'quux contents')
      Given -> @fs.outputFile.withArgs('bar', 'oof', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)
      Given -> @fs.outputFile.withArgs('blah', 'zab', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)
      Given -> @fs.outputFile.withArgs('blah', 'xuuq', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)
      When (done) ->
        @context.options = (opts) ->
          opts.actions = [
            (file) ->
              return file.contents.split(' ')[0]
          ,
            (file, cb) ->
              cb(null, file.contents.split('').reverse().join(''))
          ]
          opts
        @context.async = -> done
        @subject(@grunt)
      Then -> @grunt.log.ok.should.have.been.calledWith '3 files processed'

    context 'no dest', ->
      Given -> @context.files.push
        src: ['baz', 'quux']
      Given -> @fs.access.withArgs('baz', sinon.match.func).callsArgWith(1, null)
      Given -> @fs.readFile.withArgs('baz', { encoding: 'utf8' }, sinon.match.func).callsArgWith(2, null, 'baz contents')
      Given -> @fs.access.withArgs('quux', sinon.match.func).callsArgWith(1, null)
      Given -> @fs.readFile.withArgs('quux', { encoding: 'utf8' }, sinon.match.func).callsArgWith(2, null, 'quux contents')
      Given -> @fs.outputFile.withArgs('bar', 'oof', { encoding: 'utf8' }, sinon.match.func).callsArgWith(3, null)
      When (done) ->
        @context.options = (opts) ->
          opts.actions = [
            (file) ->
              return file.contents.split(' ')[0]
          ,
            (file, cb) ->
              cb(null, file.contents.split('').reverse().join(''))
          ]
          opts
        @context.async = -> done
        @subject(@grunt)
      Then -> @grunt.log.ok.should.have.been.calledWith '3 files processed'

  context 'failure paths :(', ->
    Given -> @fs.access.withArgs('foo', sinon.match.func).callsArgWith(1, null)
    Given -> @context =
      files: [
        src: ['foo']
        dest: 'bar'
      ]
    Given -> @grunt =
      registerMultiTask: (name, desc, fn) => fn.call(@context)
      fail:
        fatal: sinon.stub()
      log:
        ok: sinon.stub()

    context 'error reading a file', ->
      Given -> @fs.readFile.withArgs('foo', { encoding: 'utf8' }, sinon.match.func).callsArgWith(2, 'an error occurred')
      When (done) ->
        @context.options = (opts) ->
          opts.actions = []
          opts
        @context.async = -> done
        @subject(@grunt)
      Then -> @grunt.fail.fatal.should.have.been.calledWith 'an error occurred'

    context 'an error in a sync action', ->
      Given -> @fs.readFile.withArgs('foo', { encoding: 'utf8' }, sinon.match.func).callsArgWith(2, null, 'foo contents')
      When (done) ->
        @context.options = (opts) ->
          opts.actions = [
            (file) ->
              throw 'an error occurred'
          ]
          opts
        @context.async = -> done
        @subject(@grunt)
      Then -> @grunt.fail.fatal.should.have.been.calledWith 'an error occurred'

    context 'an error in an async action', ->
      Given -> @fs.readFile.withArgs('foo', { encoding: 'utf8' }, sinon.match.func).callsArgWith(2, null, 'foo contents')
      When (done) ->
        @context.options = (opts) ->
          opts.actions = [
            (file, cb) ->
              cb('an error occurred')
          ]
          opts
        @context.async = -> done
        @subject(@grunt)
      Then -> @grunt.fail.fatal.should.have.been.calledWith 'an error occurred'
