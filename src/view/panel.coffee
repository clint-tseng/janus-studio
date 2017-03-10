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
    from('context').watch('layout').and('fixture').watch('id').all.flatMap((layout, id) ->
      layout.watch("computed.#{id}.#{attr}")
    )

  @_template: template(
    find('.panel-wrapper').css('left', layoutAttr('left'))
    find('.panel-wrapper').css('top', layoutAttr('top'))
    find('.panel-wrapper').css('width', layoutAttr('width'))
    find('.panel-wrapper').css('height', layoutAttr('height'))

    find('.panel-wrapper').classed('minimized', from('minimized'))

    find('.panel-minimize').classed('disabled', from('minimized'))
    find('.panel-maximize').classed('disabled', from('maximized'))
    find('.panel-close').classed('disabled', from('has_dependencies'))

    find('.panel-contents')
      .render(from('id').and('context').all.flatMap((id, context) -> context.watch("locals.#{id}")))
      .context('panel')
  )

  _wireEvents: ->
    dom = this.artifact()
    panel = this.subject

    dom.find('.panel-minimize').on('click', -> panel.smaller())
    dom.find('.panel-maximize').on('click', -> panel.bigger())
    dom.find('.panel-close').on('click', -> panel.get('fixture').destroy())

module.exports = {
  PanelView

  registerWith: (library) -> library.register(Panel, PanelView)
}

