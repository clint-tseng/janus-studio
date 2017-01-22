{ Model, attribute, DomView, template, find, from } = require('janus')
{ isPrimitive, isArray } = require('janus').util

$ = require('jquery')

class KVPair extends Model
  constructor: (m, k) -> super({ model: m, key: k })
  @attribute('edit', attribute.TextAttribute)

  _initialize: ->
    value = this.get('model').get(this.get('key'))
    this.set('edit', if isPrimitive(value) or isArray(value) then JSON.stringify(value) else '…')
    this.watch('edit').react((raw) =>
      try
        result = (new Function("return #{raw};"))()
        this.get('model').set(this.get('key'), result)
      catch ex
        console.log("that didn't work..", ex) # TODO: surface this more usefully
    )

class KVPairView extends DomView
  @_dom: -> $('
    <div class="kvPair">
      <div class="kvPair-key"></div>
      <div class="kvPair-valueBlock">
        <div class="kvPair-value"></div>
        <div class="kvPair-edit"></div>
      </div>
    </div>
  ')
  @_template: template(
    find('.kvPair-key').text(from('key'))
    find('.kvPair-key').attr('title', from('key'))
    find('.kvPair-value').render(from('model').and('key').all.flatMap((m, k) ->
      m.watch(k).map((x) ->
        if isPrimitive(x) or isArray(x)
          JSON.stringify(x)
        else
          x
      )
    )).context('debug')
    find('.kvPair-edit').render(from.attribute('edit')).context('edit').find( attributes: { commit: 'hard' } )
  )

  _wireEvents: ->
    dom = this.artifact()
    edit = dom.find('.kvPair-edit input')

    dom.find('.kvPair-value').on('dblclick', -> edit.focus())

class ModelViewModel extends Model
  @attribute 'alignMode', class extends attribute.EnumAttribute
    values: -> [ 'natural', 'aligned' ]
    default: -> 'natural'

  @bind('pairs', from('subject').map((m) -> m.enumeration().map((k) -> new KVPair(m, k))))

class ModelView extends DomView
  @viewModelClass: ModelViewModel
  @_dom: -> $('
    <div class="modelView">
      <div class="modelView-toolbar">
        <div class="modelView-alignToggle toggleButtons ephemeral"></div>
      </div>
      <div class="modelView-title"></div>
      <div class="modelView-pairs"></div>
    </div>
  ')
  @_template: template(
    find('.modelView-alignToggle').render(from.attribute('alignMode'))
      .context('edit')
      .find( attributes: { style: 'list' } )
      .options( renderItem: (x) -> x.context('icon') )
    find('.modelView').classGroup('align-', from('alignMode'))

    find('.modelView-title').text(from('subject').map((x) -> x.constructor.name))
    find('.modelView-pairs').render(from('pairs'))
  )

module.exports = {
  KVPair, KVPairView, ModelViewModel, ModelView,

  registerWith: (library) ->
    library.register(KVPair, KVPairView)
    library.register(Model, ModelView, context: 'debug')
}

