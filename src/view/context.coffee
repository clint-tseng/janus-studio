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
    find('.context-area').classed('hasMinimized',
      from('layout').watch('minimized').flatMap((xs) -> xs.watchLength().map((l) -> l > 0)))
  )

module.exports = {
  ContextView

  registerWith: (library) -> library.register(Context, ContextView)
}

