# drop $ on the window so the stdlib picks it up (TODO: feels ugly).
$ = require('jquery')
window.jQuery = window.$ = $

{ App, Library } = require('janus')
stdlib = require('janus-stdlib')

defer = (f) -> setTimeout(f, 0)

views = new Library()
stdlib.view.registerWith(views)
require('./view/literal').registerWith(views)
require('./view/text-attribute').registerWith(views)
require('./view/icon').registerWith(views)
require('./view/flyout').registerWith(views)
require('./view/model').registerWith(views)
require('./view/varying').registerWith(views)
require('./view/mapping').registerWith(views)
require('./view/reaction').registerWith(views)
require('./view/list').registerWith(views)
require('./view/context').registerWith(views)
require('./view/panel').registerWith(views)

resolvers = new Library()

app = new App({ views, resolvers })

$ -> defer ->
  { List } = require('janus')

  { Context } = require('./model/context')
  { Fixture, Fixtures } = require('./model/fixture')
  context = window.context = new Context(
    fixtures: new Fixtures([
      new Fixture( id: 1, code: 'new Model( test: 7, test1: 2, test2: "hello", test3: { test4: 42 } )' ),
      new Fixture( id: 2, parameters: new List(1), code: "$1.watch('test').flatMap((x) -> Varying.mapAll(new Varying(1), $1.watch('test1'), new Varying(3), (a, b, c) -> a + b + c).map((c) -> c * x)).map((y) -> y + 9)" )
    ]),
    _uniqueId: 2
  )

  contextView = app.view(context)
  $('#main').append(contextView.artifact())
  contextView.wireEvents()

