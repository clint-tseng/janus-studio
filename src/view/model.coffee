{ Model, attribute, bind, DomView, template, find, from } = require('janus')
{ isPrimitive, isArray } = require('janus').util

$ = require('jquery')

class KVPair extends Model.build(attribute('edit', attribute.Text))
  constructor: (m, k) -> super({ model: m, key: k })

  _initialize: ->
    value = this.get('model').get(this.get('key'))
    this.set('edit', if isPrimitive(value) or isArray(value) then JSON.stringify(value) else '…')
    this.watch('edit').reactLater((raw) =>
      try
        result = (new Function("return #{raw};"))()
        this.get('model').set(this.get('key'), result)
      catch ex
        console.log("that didn't work..", ex) # TODO: surface this more usefully
    )

KVPairView = DomView.build($('
    <div class="kvPair">
      <div class="kvPair-key"></div>
      <div class="kvPair-valueBlock">
        <div class="kvPair-value"></div>
        <div class="kvPair-edit"></div>
      </div>
    </div>
  '), template(
    find('.kvPair-key')
      .text(from('key'))
      .attr('title', from('key'))

    find('.kvPair-edit').render(from.attribute('edit'))
      .context('edit')
      .criteria( attributes: { commit: 'hard' } )

    find('.kvPair-value')
      .render(from('model').and('key').all.flatMap((m, k) -> m.watch(k)))
        .context('debug')
      .on('dblclick', (event, _, __, dom) -> dom.find('.kvPair-edit input').focus().select())
  )
)

ModelViewModel = Model.build(
  attribute('alignMode', class extends attribute.Enum
    values: -> [ 'natural', 'aligned' ]
    default: -> 'natural'
  )

  bind('pairs', from('subject').map((m) -> m.enumeration().map((k) -> new KVPair(m, k))))
)

ModelView = DomView.build($('
    <div class="modelView panel">
      <div class="panel-toolbar">
        <div class="modelView-alignToggle toggleButtons"></div>
      </div>
      <div class="panel-title"></div>
      <div class="panel-main modelView-pairs"></div>
    </div>
  '), template(

    find('.modelView-alignToggle').render(from.attribute('alignMode'))
      .context('edit')
      .criteria( attributes: { style: 'list' } )
      .options( renderItem: (x) -> x.context('icon') )

    find('.modelView').classGroup('align-', from('alignMode'))

    find('.panel-title').text(from('subject').map((x) -> x.constructor.name))
    find('.modelView-pairs').render(from('pairs'))

  ), { viewModelClass: ModelViewModel }
)

module.exports = {
  KVPair, KVPairView, ModelViewModel, ModelView,

  registerWith: (library) ->
    library.register(KVPair, KVPairView)
    library.register(Model, ModelView, context: 'panel')
}

