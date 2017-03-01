# drop $ on the window so the stdlib picks it up (TODO: feels ugly).
$ = require('jquery')
window.jQuery = window.$ = $

{ App, Library } = require('janus').application
stdlib = require('janus-stdlib')

defer = (f) -> setTimeout(f, 0)

views = new Library()
stdlib.view.registerWith(views)
require('./view/literal').registerWith(views)
require('./view/text-attribute').registerWith(views)
require('./view/icon').registerWith(views)
require('./view/model').registerWith(views)
require('./view/varying').registerWith(views)
require('./view/reaction').registerWith(views)
require('./view/list').registerWith(views)
stores = new Library()

{ Global } = require('./model/global')
global = new Global()
app = new App({ views, stores, global })

$ -> defer ->
  { Model } = require('janus')
  window.obj = new Model( test: 1, test2: 'hello', test3: { test4: 42 } )
  debugView = app.getView(window.obj, context: 'debug-pane')
  $('#janus').append(debugView.artifact())
  debugView.wireEvents()

  { Varying } = require('janus')
  window.v = v = {}
  v.m = new Varying(1)
  v.a = new Varying(2)
  v.b = new Varying(3)
  v.c = Varying.mapAll(v.m, v.a, v.b, (m, a, b) -> m + a + b)
  v.x = new Varying(7)
  v.y = v.x.flatMap((x) -> v.c.map((c) -> c * x)).map((y) -> y + 9)
  debugVaryingView = app.getView(v.y, context: 'debug-pane')
  $('#janus').append(debugVaryingView.artifact())
  debugVaryingView.wireEvents()

