{ Model, attribute, Varying, DomView, template, find, from } = require('janus')
{ WrappedVarying } = require('../model/wrapped-varying')

$ = require('jquery')

class VaryingDebugView extends DomView
  @_dom: -> $('
    <div class="janus-varying">
      <span class="janus-debug-static">Varying[</span><div class="janus-varying-contents"/><span class="janus-debug-static">]</span>
    </div>
  ')
  @_template: template(
    find('.janus-varying-contents').render(from((x) -> x)).context('debug')
  )

class VaryingTreeView extends DomView
  @_dom: -> $('
    <div class="varyingTreeView">
      <div class="main">
        <div class="node">
          <div class="inner-marker"/>
          <div class="value-marker"/>
        </div>
        <div class="text">
          <p class="title">
            <span class="className"/>
            <span class="uid"/>
          </p>
          <div class="valueSection">
            <ul class="tags">
              <li class="tagOutdated">Outdated</li>
              <li class="tagImmediate">Immediate</li>
            </ul>
            <div class="value"/>
            <div class="delta">
              <div class="separator"/>
              <div class="newValue"/>
            </div>
          </div>
        </div>
      </div>
      <div class="aux">
        <div class="varyingTreeView-inner"/>
        <div class="mapping"><span>λ</span></div>
      </div>
      <div class="varyingTreeView-next"/>
      <div class="varyingTreeView-nexts"/>
    </div>
  ')
  @_template: template(
    find('.varyingTreeView').classed('derived', from('derived'))
    find('.varyingTreeView').classed('flattened', from('flattened'))
    find('.varyingTreeView').classed('mapped', from('mapped'))

    find('.varyingTreeView').classed('hasObservations', from('observations').flatMap((os) -> os.watchLength().map((l) -> l > 0)))
    find('.varyingTreeView').classed('hasValue', from('value').map((x) -> x?))
    find('.varyingTreeView').classed('hasInner', from('inner').map((x) -> x?))

    find('.tagOutdated').classed('hide', from('derived').and('immediate').and('value')
      .and('observations').flatMap((os) -> os.watchLength())
      .all.map((derived, immediate, value, osl) -> !derived or (osl > 0) or !(immediate? or value?)))
    find('.tagImmediate').classed('hide', from('immediate').map((x) -> !x?))

    find('.title .className').text(from('title'))
    find('.title .uid').text(from('id').map((x) -> "##{x}"))

    find('.value').render(from('immediate').and('value').all.map((i, v) -> v ? i)).context('debug')
    find('.newValue').render(from('new_value')).context(from('changed').map((changed) -> 'debug' if changed is true))

    find('.mapping').attr('title', from('target').map((varying) -> varying._f))

    find('.varyingTreeView-inner').render(from('inner').map((v) -> WrappedVarying.hijack(v) if v?)).context('tree')
    find('.varyingTreeView-next').render(from('parent').map((v) -> WrappedVarying.hijack(v) if v?)).context('tree')
    find('.varyingTreeView-nexts').render(from('parents').map((x) -> x?.map((v) -> WrappedVarying.hijack(v))))
      .context('linked').options( itemContext: 'tree' )
  )


class VaryingPanel extends Model
  @attribute('subscribed', attribute.BooleanAttribute)

  @attribute('active_reaction', class extends attribute.EnumAttribute
    nullable: true
    values: -> this.model.watch('wrapped').flatMap((wv) -> wv.watch('reactions'))
    default: -> null
  )

  @bind('wrapped', from('subject').map((varying) -> WrappedVarying.hijack(varying)))

  _initialize: ->
    # create or destroy our own hollow observation:
    this.watch('subscribed').react((subbed) =>
      if subbed
        this._observation = this.get('subject').reactNow(->)
      else
        this._observation.stop()
    )

class VaryingView extends DomView
  @viewModelClass: VaryingPanel

  @_dom: -> $('
    <div class="varyingView panel hasSidebar">
      <div class="panel-toolbar">
        <ul class="varyingView-subscriptionToggle toggleSwitch">
          <li><div class="icon icon-plug"></div></li>
          <li class="switch"></li>
        </ul>
      </div>
      <div class="panel-title"></div>
      <div class="varyingView-clearActive"><span class="icon"/></div>
      <div class="panel-main varyingView-tree"></div>
      <div class="panel-sidebar varyingView-reactions"></div>
    </div>
  ')
  @_template: template(
    find('.panel-title').text(from('wrapped').watch('title'))

    find('.varyingView-subscriptionToggle').classed('checked', from('subscribed'))
    find('.varyingView-subscriptionToggle .switch').render(from.attribute('subscribed'))
      .context('edit').find( attributes: { style: 'button' } )

    find('.varyingView-tree').render(from('wrapped').and('active_reaction').all.flatMap((wv, ar) ->
      if ar? then wv.watch('id').flatMap((id) -> ar.watch("tree.#{id}")) else wv
    )).context('tree')

    find('.varyingView-reactions').render(from.attribute('active_reaction'))
      .context('edit').find( attributes: { style: 'list' } )
  )


module.exports = {
  VaryingView
  VaryingTreeView

  registerWith: (library) ->
    library.register(Varying, VaryingDebugView, context: 'debug')
    library.register(WrappedVarying, VaryingTreeView, context: 'tree')
    library.register(Varying, VaryingView, context: 'debug-pane')
}

