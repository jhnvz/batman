Batman = require '../../batman'
Watson = require 'watson'
Random = require '../lib/number_generator.coffee'
Clunk = require '../lib/clunk.coffee'

# Fix deferred loop rendering to actually happen, and always fire the parent's rendered event
# Needed for the ::deferEvery settings below.
Watson.ensureCommitted '6d132e078e3e07473b538ab157635b8664e2077e', ->
  Watson.makeADom()

  loopSource = '''
  <div data-foreach-obj="objects">
    <span data-bind="obj"></span>
    <span data-bind="obj"></span>
    <span data-bind="obj"></span>
    <span data-bind="obj"></span>
    <span data-bind="obj"></span>
    <span data-bind="obj"></span>
  </div>
  '''

  objects = new Batman.Set([0...50])
  view = new Batman.View
    objects: objects
    html: loopSource

  run = ->
    Watson.trackMemory 'view memory usage: loop rendering with clear', 1000, 5, (i) ->
      objects.add(i)
      if i % 300 == 0
        objects.clear()

  view.get('node')
  view.initializeBindings()
  view.on 'ready', run

