Batman = require '../../batman'
Watson = require 'watson'
jsdom = require 'jsdom'

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

Watson.trackMemory 'view memory usage: simple', 400, {step: 10, async: true}, (i, next) ->
  context = Batman(objects: new Batman.Set([0...50]))

  view = new Batman.View
    objects: context
    html: loopSource
  view.get('node')
  view.initializeBindings()

  view.on 'ready', next
