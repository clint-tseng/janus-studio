{ Model, bind, from } = require('janus')

class Panel extends Model.build(
    bind('id', from('fixture').watch('id'))

    bind('minimized', from('id')
      .and('context').watch('layout').watch('minimized')
      .all.flatMap((id, ms) -> ms?.any((x) -> x is id)))
    bind('maximized', from('id')
      .and('context').watch('layout').watch('maximized')
      .all.flatMap((id, ms) -> ms?.any((x) -> x is id)))

    bind('has_dependencies', from('id')
      .and('context').watch('fixtures')
      .all.flatMap((id, fixtures) ->
        fixtures.any((fixture) -> fixture.watch('parameters').flatMap((ps) -> ps.any((p) -> p is id)))
      ))
  )

  constructor: (context, fixture) -> super({ context, fixture })

  bigger: ->
    layout = this.get('context').get('layout')
    if this.get('minimized') is true
      layout.get('minimized').remove(this.get('id'))
    else if this.get('maximized') isnt true
      layout.get('maximized').add(this.get('id'))

  smaller: ->
    layout = this.get('context').get('layout')
    if this.get('maximized') is true
      layout.get('maximized').remove(this.get('id'))
    else if this.get('minimized') isnt true
      layout.get('minimized').add(this.get('id'))

  _initialize: ->
    # TODO: feels a little awkward here.
    this.watch('fixture').react((fixture) =>
      fixture.on('destroying', =>
        if (layout = this.get('context')?.get('layout'))?
          id = this.get('id')
          layout.get('minimized').remove(id)
          layout.get('maximized').remove(id)
      )
    )

module.exports = { Panel }

