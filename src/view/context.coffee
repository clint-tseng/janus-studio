{ DomView, template, find, from } = require('janus')
$ = require('jquery')

{ Context } = require('../model/context')

class ContextView extends DomView
  @_dom: -> $('
    <div class="context">
      <div class="context-area"/>
    </div>
  ')
  @_template: template(
    find('.context-area').render(from('panels'))
  )

module.exports = {
  ContextView

  registerWith: (library) -> library.register(Context, ContextView)
}

