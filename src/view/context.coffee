{ DomView, template, find, from } = require('janus')
$ = require('jquery')

{ Context } = require('../model/context')

class ContextView extends DomView
  @_dom: -> $('
    <div class="context">
      <div class="context-area"/>
      <div class="prompt">
        <div class="prompt-prefix">
          <div class="prompt-locals">
            <span>(</span>
            <div class="prompt-localsList"/>
            <span>) -></span>
          </div>
        </div>
        <div class="prompt-textContainer">
          <textarea></textarea>
        </div>
      </div>
    </div>
  ')
  @_template: template(
    find('.context-area').render(from('panels'))
    find('.context-area').classed('hasMinimized',
      from('layout').watch('minimized').flatMap((xs) -> xs.watchLength().map((l) -> l > 0)))

    find('.prompt-localsList').render(from('prompt').watch('parameters'))
    find('.prompt-locals').classed('hide', from('prompt').watch('parameters').flatMap((ps) -> ps.watchLength().map((l) -> l is 0)))
    find('.prompt-textContainer').render(from('prompt').map((p) -> p.attribute('code')))
      .context('edit').find( attributes: { style: 'multiline' } )
  )

  _wireEvents: ->
    dom = this.artifact()
    context = this.subject

    dom.find('.prompt-textContainer').on('keydown', 'textarea', (event) ->
      if event.which is 13
        context.commitPrompt()
    )

module.exports = {
  ContextView

  registerWith: (library) -> library.register(Context, ContextView)
}

