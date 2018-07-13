{ DomView, template, find, from } = require('janus')
$ = require('jquery')

{ Context } = require('../model/context')

ContextView = DomView.build($('
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
  '), template(

    find('.context-area').render(from('panels'))
    find('.context-area').classed('hasMinimized',
      from('layout').watch('minimized').flatMap((xs) -> xs.watchLength().map((l) -> l > 0)))

    find('.prompt-localsList').render(from('prompt').watch('parameters'))
    find('.prompt-locals').classed('hide', from('prompt').watch('parameters').flatMap((ps) -> ps.watchLength().map((l) -> l is 0)))

    find('.prompt-textContainer')
      .render(from('prompt').map((p) -> p.attribute('code')))
        .context('edit').criteria( attributes: { style: 'multiline' } )
      .on('keydown', 'textarea', (event, context) -> context.commitPrompt() if event.which is 13)
  )
)

module.exports = {
  ContextView

  registerWith: (library) -> library.register(Context, ContextView)
}

