# drop $ on the window so the stdlib picks it up (TODO: feels ugly).
$ = require('jquery')
window.jQuery = window.$ = $

{ App, Library } = require('janus').application
stdlib = require('janus-stdlib')

views = new Library()
stdlib.view.registerWith(views)
require('./view/model').registerWith(views)
stores = new Library()

app = new App({ views, stores })

$ ->
  { Model } = require('janus')
  window.obj = new Model()
  debugView = app.getView(window.obj, context: 'debug')
  $('#janus').append(debugView.artifact())
  debugView.wireEvents()

