{ DomView, template, find, from } = require('janus')
$ = require('jquery')

{ Panel } = require('../viewmodel/panel')

class PanelView extends DomView
  @_dom: -> $('
    <div class="panel-wrapper">
      <div class="panel-wrapperToolbar">
        <a class="panel-minimize"/>
        <a class="panel-maximize"/>
        <a class="panel-close"/>
      </div>
      <div class="panel-contents"/>
    </div>
  ')

  layoutAttr = (attr) ->
    from('context').and('fixture').watch('id').all.flatMap((context, id) ->
      context.watch("layout.computed.#{id}.#{attr}")
    )

  @_template: template(
    find('.panel-wrapper').css('left', layoutAttr('left'))
    find('.panel-wrapper').css('top', layoutAttr('top'))
    find('.panel-wrapper').css('width', layoutAttr('width'))
    find('.panel-wrapper').css('height', layoutAttr('height'))

    find('.panel-contents').render(from('fixture').watch('id').and('context').all.flatMap((id, context) ->
      context.watch("locals.#{id}")
    )).context('panel')
  )

module.exports = {
  PanelView

  registerWith: (library) -> library.register(Panel, PanelView)
}

