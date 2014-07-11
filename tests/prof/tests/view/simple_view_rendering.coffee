Batman = require '../../batman'
Watson = require 'watson'
jsdom = require 'jsdom'

Watson.makeADom()

simpleSource = '''
<div data-bind="foo"></div>
'''

loopSource = '''
<div data-foreach-obj="objects">
  <span data-bind="obj"></span>
</div>
'''

nestedLoopSource = '''
<div data-foreach-key="keys">
  <div data-foreach-val="sets[key]">
    <span data-bind="val"></span>
  </div>
</div>
'''

Watson.benchmark 'simple view rendering', (error, suite) ->
  throw error if error

  do ->
    suite.add('simple bindings rendering',((deferred) ->
      view = new Batman.View
        foo: 'bar'
        html: simpleSource
      view.get('node')
      view.initializeBindings()
      view.on 'ready', -> deferred.resolve()
    ),{
      defer: true
    })

  do ->
    suite.add('simple loop rendering', ((deferred) ->
      view = new Batman.View
        objects: new Batman.Set([0...100])
        html: loopSource
      view.get('node')
      view.initializeBindings()
      view.on 'ready', -> deferred.resolve()
    ),{
      defer: true
      maxTime: 6
    })

  do ->
    suite.add('nested loop rendering', ((deferred) ->
      view = new Batman.View
        keys: ['foo', 'bar', 'baz', 'qux']
        sets: new Batman.Hash
          foo: new Batman.Set([0...100])
          bar: new Batman.Set([0...100])
          baz: new Batman.Set([0...100])
          qux: new Batman.Set([0...100])
        html: nestedLoopSource
      view.get('node')
      view.initializeBindings()
      view.on 'ready', -> deferred.resolve()
    ),{
      maxTime: 10
      defer: true
    })

  suite.run()
