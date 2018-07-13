{ DomView, template, find, from } = require('janus')
$ = require('jquery')

{ Panel } = require('../viewmodel/panel')

layoutAttr = (attr) ->
  from('context').watch('layout')
    .and('fixture').watch('id')
    .all.flatMap((layout, id) -> layout.watch("computed.#{id}.#{attr}"))

PanelView = DomView.build($('
    <div class="panel-wrapper">
      <div class="panel-wrapperToolbar panel-wrapperSubjectControls">
        <a class="panel-var"/>
      </div>
      <div class="panel-wrapperToolbar panel-wrapperWindowControls">
        <a class="panel-minimize"/>
        <a class="panel-maximize"/>
        <a class="panel-close"/>
      </div>
      <div class="panel-contents"/>
    </div>
  '), template(

    find('.panel-wrapper')
      .css('left', layoutAttr('left'))
      .css('top', layoutAttr('top'))
      .css('width', layoutAttr('width'))
      .css('height', layoutAttr('height'))

      .classed('minimized', from('minimized'))

    find('.panel-minimize')
      .classed('disabled', from('minimized'))
      .on('click', (_, panel) -> panel.smaller())

    find('.panel-maximize')
      .classed('disabled', from('maximized'))
      .on('click', (_, panel) -> panel.bigger())

    find('.panel-close')
      .classed('disabled', from('has_dependencies'))
      .on('click', (event, panel) -> panel.get('fixture').destroy() unless $(event.target).hasClass('disabled'))

    find('.panel-contents')
      .render(from('id').and('context').all.flatMap((id, context) -> context.watch("locals.#{id}")))
      .context('panel')

    find('.panel-var').on('click', (_, panel) ->
      panel.get('context').get('prompt').get('parameters').add(panel.get('id'))
    )
  )
)


module.exports = {
  PanelView

  registerWith: (library) -> library.register(Panel, PanelView)
}

