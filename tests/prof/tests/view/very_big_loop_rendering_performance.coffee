Batman = require '../../batman'
Watson = require 'watson'

Watson.makeADom()

getSet = (limit = 1000)->
  set = new Batman.Set
  set.add(i) for i in [1..limit]
  set

Watson.benchmark 'IteratorBinding performance', (error, suite) ->
  throw error if error

  root = document.body
  context = false
  view = false
  node = false

  setContext = (count) ->
    context = {items: getSet(count)}

  setNode    = (source) ->
    Batman.DOM.destroyNode(node) if node
    node = document.createElement("div")
    node.innerHTML = source
    node

  do ->
    source = """
      <div data-foreach-item="items">
        <span data-bind="item"></span>
        <span data-bind="item"></span>
        <span data-bind="item"></span>
      </div>
    """

    suite.add "loop over an array of 200 items with 3 bindings", (deferred) ->
      viewOptions = Batman.mixin({}, context, {html: source})
      view = new Batman.View(viewOptions)
      view.get('node')
      view.initializeBindings()
      view.on 'ready', ->
        deferred.resolve()
    , {
      onCycle: ->
        setContext(200)
      onStart: ->
        setContext(200)
      defer: true
      minSamples: 30
    }

    suite.add "loop over an array of 400 items with 3 bindings", (deferred) ->
      view = new Batman.View Batman.mixin({}, context, {html: source})
      view.get('node')
      view.initializeBindings()
      view.on 'ready', ->
        deferred.resolve()
    , {
      onCycle: ->
        setContext(400)
      onStart: ->
        setContext(400)
      defer: true
      minSamples: 30
    }

  do ->
    source = """
      <div data-foreach-item="items">
        <p data-bind="item" data-bind-class="item">
          <span data-showif="item"></span>
          <span data-insertif="item"></span>
          Foo bar
          <span data-insertif="item"></span>
          <select>
            <option data-bind="item"></option>
          </select>
        </p>
        <p>Baz</p>
      </div>
    """

    suite.add "loop over an array of 200 items with repaint-y bindings", (deferred) ->
      view = new Batman.View Batman.mixin({}, context, {html: source})
      view.get('node')
      view.initializeBindings()
      view.on 'ready', -> deferred.resolve()
    , {
      onCycle: ->
        setContext(200)
      onStart: ->
        setContext(200)
      defer: true
      minSamples: 30
    }

  suite.run()
