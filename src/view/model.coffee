{ Model, DomView, template, find, from } = require('janus')

$ = require('jquery')

class KVPair extends Model
  constructor: (k, v) -> super({ key: k, value: v })

class KVPairView extends DomView
  @_dom: -> $('
    <div class="kvPair">
      <span class="kvPair-key"></span>
      <span class="kvPair-value"></span>
    </div>
  ')
  @_template: template(
    find('.kvPair-key').text(from('key'))
    find('.kvPair-value').render(from('value'))
  )

class ModelViewModel extends Model
  @bind('pairs', from('subject').map((x) -> x.enumeration().map((k) -> new KVPair(k, x.watch(k)))))

class ModelView extends DomView
  @viewModelClass: ModelViewModel
  @_dom: -> $('
    <div class="modelView">
      <div class="modelView-title"></div>
      <div class="modelView-pairs"></div>
    </div>
  ')
  @_template: template(
    find('.modelView-title').text(from('subject').map((x) -> x.constructor.name))
    find('.modelView-pairs').render(from('pairs'))
  )

module.exports = {
  KVPair, KVPairView, ModelViewModel, ModelView,

  registerWith: (library) ->
    library.register(KVPair, KVPairView)
    library.register(Model, ModelView, context: 'debug')
}

