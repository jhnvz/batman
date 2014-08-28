test "decodeKey registers the encoder and decoder key", ->
  class @Product extends Batman.Model
    @decodeKey 'product_variations', 'product_variations_attributes'
  class @ProductVariation extends Batman.Model
    @decodeKey 'properties', 'properties_attributes'

  product = new @Product
  variation = new @ProductVariation

  deepEqual product._batman.get('decoderKeys'), { 'product_variations': 'product_variations_attributes' }
  deepEqual variation._batman.get('decoderKeys'), { 'properties': 'properties_attributes' }

test 'toJSON replaces encoder keys with decoder keys', ->
  class @Store extends Batman.Model
    @encode 'id', 'name'

  class @Product extends Batman.Model
    @encode 'id', 'name', 'cost'
    @hasMany 'properties'
    @decodeKey 'properties', 'properties_attributes'

  class @Property extends Batman.Model
    @encode 'id', 'name', 'value'

  @Store.hasMany('products', saveInline: true, autoload: false, namespace: @, decoderKey: 'products_attributes')
  @Product.hasMany('properties', saveInline: true, autoload: false, namespace: @)

  store  = new @Store(name: "Goodburger")
  burger = store.get('products').build(name: "The Goodburger")
  fries  = store.get('products').build(name: "French Fries")

  store.get('products').at(0).get('properties').build(name: 'SKU', value: 'B1')

  JSONResponse = store.toJSON()

  deepEqual JSONResponse, {
	  "name": "Goodburger",
	  "products_attributes": [
	    {
	      "name": "The Goodburger",
	      "properties_attributes": [
	        {
	          "name": "SKU",
	          "product_id": undefined,
	          "value": "B1"
	        }
	      ],
	      "store_id": undefined
	    },
	    {
	      "name": "French Fries",
	      "properties_attributes": [],
	      "store_id": undefined
	    }
	  ]
	}
