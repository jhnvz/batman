{createStorageAdapter, TestStorageAdapter, AsyncTestStorageAdapter} = window
helpers = window.viewHelpers

QUnit.module "Batman.Model Associations",
  setup: ->
    @oldApp = Batman.currentApp

  teardown: ->
    Batman.currentApp = @oldApp

test "association macros without options", ->
  app = Batman.currentApp = {}
  class app.Card extends Batman.Model
    @belongsTo 'deck'
  class app.Deck extends Batman.Model
    @hasMany 'cards'
    @belongsTo 'player'
  class app.Player extends Batman.Model
    @hasOne 'deck'

  player = new app.Player
  deck = new app.Deck
  card = new app.Card

  ok player.get('deck') instanceof Batman.HasOneProxy
  ok deck.get('player') instanceof Batman.BelongsToProxy
  ok deck.get('cards') instanceof Batman.AssociationSet
  ok card.get('deck') instanceof Batman.BelongsToProxy

asyncTest "association load passes env", 1, ->
  app = Batman.currentApp = {}

  class app.Card extends Batman.Model
    @belongsTo 'deck'
  class app.Deck extends Batman.Model
    @hasMany 'cards'

  adapter = createStorageAdapter app.Card, AsyncTestStorageAdapter,
    'cards': [ {name: "Card One", id: 1, deck_id: 1} ]

  deck = new app.Deck
    id: 1

  deck.get('cards').load (err, records, env) ->
    deepEqual env, {}
    QUnit.start()

asyncTest "load can have options", 2, ->
  namespace = {}

  class namespace.Store extends Batman.Model
    @encode 'name', 'id'
    @hasMany 'products', {namespace: namespace, autoload: false}

  @storeAdapter = createStorageAdapter namespace.Store, AsyncTestStorageAdapter,
    stores1: {id: 1, name: "Store One"}

  class namespace.Product extends Batman.Model
    @encode 'name', 'id'
    @belongsTo 'store', {namespace: namespace}

  @productAdapter = createStorageAdapter namespace.Product, AsyncTestStorageAdapter,
    products1: {id: 1, name: 'Product One', store_id: 1}

  associationSpy = spyOn(@productAdapter, 'perform')

  namespace.Store.find 1, (err, store) =>
    products = store.get('products')
    products.load {key1: 'value1'}, (err, comments) ->
      throw err if err
      equal associationSpy.lastCallArguments[2].data['store_id'], 1
      equal associationSpy.lastCallArguments[2].data['key1'], 'value1'
      QUnit.start()

asyncTest "support custom model namespaces and class names", 2, ->
  namespace = {}
  class namespace.Walmart extends Batman.Model
    @encode 'name', 'id'

  class Product extends Batman.Model
    @belongsTo 'store',
      namespace: namespace
      name: 'Walmart'
    @encode 'name', 'id'

  productAdapter = createStorageAdapter Product, AsyncTestStorageAdapter,
    'products2': {name: "Product Two", id: 2, store: {id:3, name:"JSON Store"}}

  Product.find 2, (err, product) ->
    store = product.get('store')
    ok store instanceof namespace.Walmart
    equal store.get('id'), 3
    QUnit.start()

test "supports the nestUrl option if the model is persisted ", ->
  app = Batman.currentApp = {}

  class app.Deck extends Batman.Model
    @hasMany 'cards'

  class app.Card extends Batman.Model
    @persist Batman.RestStorage
    @belongsTo 'deck', nestUrl: true

  deck = new app.Deck(id: 10)
  card = new app.Card(id: 20)
  card.set 'deck_id', deck.get('id')

  equal card.url(), 'decks/10/cards/20'

test "decoderKey option registers the encoder and decoder key on the model", ->
  app = Batman.currentApp = {}

  class app.Deck extends Batman.Model
    @hasMany 'cards', decoderKey: 'cards_attributes'

  class app.Card extends Batman.Model
    @belongsTo 'deck', decoderKey: 'deck_attributes'

  deck = new app.Deck
  card = new app.Card

  deepEqual deck._batman.get('decoderKeys'), { "cards": "cards_attributes" }
  deepEqual card._batman.get('decoderKeys'), { "deck": "deck_attributes" }

asyncTest "support custom exensions which get applied before accessors or encoders", 2, ->
  namespace = {}
  class namespace.Walmart extends Batman.Model
    @encode 'name', 'id'

  class Product extends Batman.Model
    @encode 'name', 'id'
    @belongsTo 'store',
      namespace: namespace
      name: 'Walmart'
      extend: {label: 'foo'}

  productAdapter = createStorageAdapter Product, AsyncTestStorageAdapter,
    'products2': {name: "Product Two", id: 2, foo: {id:3, name:"JSON Store"}}

  Product.find 2, (err, product) ->
    store = product.get('foo')
    ok store instanceof namespace.Walmart, "The store is accessible as 'foo'"
    equal store.get('id'), 3
    QUnit.start()

asyncTest "supports encoder keys to serialize and deserialize the association to", 2, ->
  namespace = {}
  class namespace.Walmart extends Batman.Model
    @encode 'name', 'id'

  class Product extends Batman.Model
    @encode 'name', 'id'
    @belongsTo 'store',
      namespace: namespace
      name: 'Walmart'
      encoderKey: 'foo'

  productAdapter = createStorageAdapter Product, AsyncTestStorageAdapter,
    'products2': {name: "Product Two", id: 2, foo: {id:3, name:"JSON Store"}}

  Product.find 2, (err, product) ->
    store = product.get('foo')
    ok store instanceof namespace.Walmart
    equal store.get('id'), 3
    QUnit.start()

asyncTest "associations can be inherited", 2, ->
  namespace = {}
  class namespace.Store extends Batman.Model
    @encode 'name', 'id'

  class namespace.TestModel extends Batman.Model
    @belongsTo 'store', {namespace: namespace, autoload: false}

  class namespace.Product extends namespace.TestModel
    @encode 'name', 'id'

  storeAdapter = createStorageAdapter namespace.Store, AsyncTestStorageAdapter,
    'stores2': {name: "Store Two", id: 2}

  product = new namespace.Product({id: 2, store_id: 2})
  product.get('store').load (err, store) ->
    throw err if err
    ok store instanceof namespace.Store
    equal store.get('name'), "Store Two"
    QUnit.start()

asyncTest "support model classes that haven't been loaded yet", 2, ->
  namespace = this
  class @Blog extends Batman.Model
    @encode 'id', 'name'
    @hasOne 'customer', namespace: namespace
  blogAdapter = createStorageAdapter @Blog, AsyncTestStorageAdapter,
    'blogs1': {name: "Blog One", id: 1}

  setTimeout (=>
    class @Customer extends Batman.Model
      @encode 'id', 'name'
      @belongsTo 'blog'
    customerAdapter = new AsyncTestStorageAdapter @Customer
    customerAdapter.storage =
      'customer1': {name: "Customer One", id: 1, blog_id: 1}
    @Customer.persist customerAdapter

    @Blog.find 1, (err, blog) =>
      customer = blog.get 'customer'
      delay ->
        equal customer.get('id'), 1
        equal customer.get('name'), 'Customer One'
  ), ASYNC_TEST_DELAY

asyncTest "models can save while related records are loading", 1, ->
  namespace = this
  class @Store extends Batman.Model
    @hasOne 'product', namespace: namespace
  storeAdapter = createStorageAdapter @Store, AsyncTestStorageAdapter,
    "stores1": {id: 1, name: "Store One", product: {id: 1, name: "JSON product"}}

  class @Product extends Batman.Model
    @encode 'name'

  productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter

  Batman.developer.suppress =>
    @Store.find 1, (err, store) ->
      product  = store.get 'product'
      product._batman.state = 'loading'
      store.save (err, savedStore) ->
        ok !err
        QUnit.start()

asyncTest "inline saving can be disabled", 1, ->
  namespace = this

  class @Store extends Batman.Model
    @hasMany 'products',
      namespace: namespace
      saveInline: false

  @storeAdapter = createStorageAdapter @Store, AsyncTestStorageAdapter,
    "stores1": {id: 1, name: "Store One"}

  class @Product extends Batman.Model
    @encode 'name'

  @productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter

  @Store.find 1, (err, store) =>
    store.set 'products', new Batman.Set([new @Product])
    store.save (err, savedStore) =>
      equal @storeAdapter.storage.stores1["products"], undefined
      QUnit.start()

asyncTest "no encoder is added to the model if saveInline is false", 1, ->
  namespace = this

  class @Store extends Batman.Model
    @hasMany 'products',
      namespace: namespace
      saveInline: false

  @storeAdapter = createStorageAdapter @Store, AsyncTestStorageAdapter,
    "stores1": {id: 1, name: "Store One"}

  class @Product extends Batman.Model
    @encode 'name'

  @productAdapter = createStorageAdapter @Product, AsyncTestStorageAdapter

  @Store.find 1, (err, store) =>
    throw err if err
    equal typeof store._batman.get('encoders').get('products').encoder, 'undefined'
    QUnit.start()

test "associations support names that end with ss", ->
  app = Batman.currentApp = {}

  class app.Address extends Batman.Model
    @belongsTo 'location'
  class app.Location extends Batman.Model
    @hasOne 'address'
  class app.Rolodex extends Batman.Model
    @hasMany 'addresses'

  loc = new app.Location()
  associationName = loc.reflectOnAssociation('address').options.name
  equal associationName, 'Address'

  rol = new app.Rolodex()
  associationName = rol.reflectOnAssociation('addresses').options.name
  equal associationName, 'Address'
