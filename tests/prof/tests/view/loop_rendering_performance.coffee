Batman = require '../../batman'
Watson = require 'watson'
jsdom = require 'jsdom'

getSet = (limit = 1000)->
  set = new Batman.Set
  set.add(i) for i in [1..limit]
  set

getObjectSet = (limit = 1000)->
  set = new Batman.Set
  set.add(Batman(num: i)) for i in [1..limit]
  set

Watson.benchmark 'IteratorBinding performance', (error, suite) ->
  throw error if error

  for count in [50, 100, 150]
    do (count) ->
      source = """
        <div data-foreach-item="items"></div>
      """
      items = null

      do setup = ->
        items = getSet(count)

      suite.add "loop over an array of #{count} items", (deferred) ->
        view = new Batman.View
          items: items
          html: source
        view.on 'ready', ->
          deferred.resolve()
        view.get('node')
        view.initializeBindings()
      , {
        onCycle: -> setup()
        defer: true
        minSamples: 10
      }

  do ->
    source = """
      <div data-foreach-item="items"></div>
    """
    items = null

    do setup = ->
      items = getObjectSet(100).sortedBy('num')

    suite.add "move one item from the top to the bottom of the set", (deferred) ->
      view = new Batman.View
        items: items
        html: source
      view.on 'ready', ->
        items.get('first').set('num', 101)
        deferred.resolve()
      view.get('node')
      view.initializeBindings()
    , {
      onCycle: -> setup()
      defer: true
      minSamples: 10
    }

  do ->
    source = """
      <div data-foreach-item="items"></div>
    """
    items = set = null

    do setup = ->
      set = getObjectSet(100)
      items = set.sortedBy('num')

    suite.add "reverse the set", (deferred) ->
      view = new Batman.View
        items: items
        html: source
      view.on 'ready', ->
        @set('items', set.sortedBy('num', 'desc'))
        deferred.resolve()
      view.get('node')
      view.initializeBindings()
    , {
      onCycle: -> setup()
      defer: true
      minSamples: 10
    }

  suite.run()
