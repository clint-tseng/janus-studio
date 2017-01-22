# drop $ on the window so the stdlib picks it up (TODO: feels ugly).
$ = require('jquery')
window.jQuery = window.$ = $

{ App, Library } = require('janus').application
stdlib = require('janus-stdlib')

defer = (f) -> setTimeout(f, 0)

views = new Library()
stdlib.view.registerWith(views)
require('./view/text-attribute').registerWith(views)
require('./view/icon').registerWith(views)
require('./view/model').registerWith(views)
stores = new Library()

app = new App({ views, stores })

$ -> defer ->
  { Model } = require('janus')
  window.obj = new Model( test: 1, test2: 'hello', test3: { test4: 42 } )
  debugView = app.getView(window.obj, context: 'debug')
  $('#janus').append(debugView.artifact())
  debugView.wireEvents()

