Batman = require '../../batman'
Watson = require 'watson'
jsdom = require 'jsdom'

# Addition of ViewSourceCache
Watson.ensureCommitted "326f4a52d83b3871ff79a8b6fff4c51f24771fd6", ->
  global.window = jsdom.jsdom("<html><head><script></script></head><body></body></html>").createWindow()
  global.document = window.document

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
  Batman.View.store.set '/a/test/path', loopSource

  # Batman.Renderer::deferEvery = false if Batman.Renderer::deferEvery

  Watson.trackMemory 'view memory usage: source cache', 20, {step: 1, async: true}, (i, next) ->
    view = new Batman.View
      objects: new Batman.Set([0...50])
      source: 'a/test/path'
    view.get('node')
    view.initializeBindings()

    finish = ->
      Batman.DOM.destroyNode(view.get('node'))
      next()

    view.on 'ready', finish


