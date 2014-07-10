var path = require('path')
var jsdom = require('jsdom').jsdom
var window = jsdom().parentWindow
var document = window.document
global.document = document
global.navigator = {}

var batmanPath = './build/batman.js'
var batmanSoloAdapterPath = './build/batman.solo.js'
// read the file, then eval it since batman.js doesn't actually export anything

eval(require('fs').readFileSync(path.resolve(__dirname, batmanPath), 'utf8'))
eval(require('fs').readFileSync(path.resolve(__dirname, batmanSoloAdapterPath), 'utf8'))

module.exports = Batman
