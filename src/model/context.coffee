{ Model, attribute, from, Varying, List } = require('janus')
{ compile } = require('livescript')

{ Fixtures } = require('./fixture')
{ Layout } = require('./layout')
{ Panel } = require('../viewmodel/panel')


# TODO: someday should be able to have nonlive contexts.
class FixtureBinding extends Model
  constructor: (context, fixture) -> super({ context, fixture })

  _initialize: ->
    this.destroyWith(this.get('context'))
    this._spawner = this._spawn().reactNow((result) =>
      #TODO: is there a cleverer way to get these values short of returning a tuple?
      context = this.get('context')
      id = this.get('fixture').get('id')

      if result instanceof Error
        context.unset("locals.#{id}")
      else
        console.log(result)
        context.set("locals.#{id}", result)

      result
    )

  _spawn: ->
    Varying.flatMapAll(this.watch('context'), this.watch('fixture'), (context, fixture) ->
      Varying.flatMapAll(fixture.watch('id'), fixture.watch('code'), fixture.watch('parameters'), (id, code, ps) ->
        requires = compile('{ Model, List, Varying } = require("janus")\n', bare: true, header: false )
        wrappedCode = 'do ->\n' + ("  #{line}" for line in code.split('\n')).join('')
        compiled = requires + 'return ' + compile(wrappedCode, bare: true, header: false )

        Varying.managed((-> ps.map((p) -> "$#{p}").concat(new List(compiled))), (list) ->
          list.apply((args...) ->
            f = new Function(args...)
            Varying.managed((-> ps.flatMap((p) -> context.watch("locals.#{p}"))), (values) -> values.apply(f))
          ).flatten()
        )
      )
    )

  destroy: ->
    this._spawner.stop()
    super()

class Context extends Model
  @attribute('fixtures', class extends attribute.CollectionAttribute
    default: -> new Fixtures()
  )

  @attribute('_uniqueId', class extends attribute.NumberAttribute
    default: -> 0
    writeDefault: true
  )

  @transient('locals')
  @transient('bindings')
  @bind('bindings', from.self().and('fixtures').all.map((context, fixtures) ->
    # TODO: destroy dead bindings
    fixtures.map((fixture) -> new FixtureBinding(context, fixture))
  ))

  @transient('panels')
  @bind('panels', from.self().and('fixtures').all.map((context, fixtures) ->
    fixtures.map((fixture) -> new Panel(context, fixture)))
  )

  @attribute('layout', class extends attribute.ModelAttribute
    @modelClass: Layout
    default: -> new Layout()
  )

  _initialize: ->
    this.watch('layout').reactNow((layout) => layout.set('context', this))

  _uniqueId: -> this.set('_uniqueId', this.get('_uniqueId' + 1))


module.exports = { Context }

