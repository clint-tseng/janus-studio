{ Model, attribute, bind, Varying, DomView, template, from } = require('janus')
{ WrappedVarying } = require('../model/wrapped-varying')
find = require('./mutators')

$ = require('jquery')

VaryingDebugView = DomView.build($('
    <div class="janus-varying">
      <span class="janus-debug-static">Varying[</span><div class="janus-varying-contents"/><span class="janus-debug-static">]</span>
    </div>
  '),
  find('.janus-varying-contents').render(from((x) -> x)).context('debug')
)

VaryingDeltaView = DomView.build($('
    <div class="varyingDelta">
      <div class="value"/>
      <div class="delta">
        <div class="separator"/>
        <div class="newValue"/>
      </div>
    </div>
  '), template(

    find('.value').render(from('immediate').and('value').all.map((i, v) -> v ? i)).context('debug')
    find('.newValue').render(from('new_value')).context(from('changed').map((changed) -> 'debug' if changed is true))

    find('.varyingDelta').classed('hasDelta', from('changed'))
  )
)

VaryingTreeView = DomView.build($('
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
            <div class="valueContainer"/>
          </div>
        </div>
      </div>
      <div class="aux">
        <div class="varyingTreeView-inner varyingTreeView-innerNew"/>
        <div class="varyingTreeView-inner varyingTreeView-innerMain"/>
        <div class="mapping"><span>λ</span></div>
      </div>
      <div class="varyingTreeView-next"/>
      <div class="varyingTreeView-nexts"/>
    </div>
  '), template(

    find('.varyingTreeView')
      .classed('derived', from('derived'))
      .classed('flattened', from('flattened'))
      .classed('mapped', from('mapped'))

      .classed('hasObservations', from('observations').flatMap((os) -> os.watchLength().map((l) -> l > 0)))
      .classed('hasValue', from('value').map((x) -> x?))
      .classed('hasInner', from('inner').map((x) -> x?))

    find('.tagOutdated').classed('hide', from('derived').and('immediate').and('value')
      .and('observations').flatMap((os) -> os.watchLength())
      .all.map((derived, immediate, value, osl) -> !derived or (osl > 0) or !(immediate? or value?)))
    find('.tagImmediate').classed('hide', from('immediate').map((x) -> !x?))

    find('.title .className').text(from('title'))
    find('.title .uid').text(from('id').map((x) -> "##{x}"))

    find('.valueContainer').render(from((x) -> x)).context('delta') # TODO: ehhh on this context name?

    find('.mapping').flyout(from((x) -> x).and('mapped').all.map((wv, mapped) -> wv if mapped is true)).context('mapping')

    find('.varyingTreeView-innerNew')
      .classed('hasNewInner', from('new_inner').map((x) -> x?))
      .render(from('new_inner').map((v) -> WrappedVarying.hijack(v) if v?)).context('tree')
    find('.varyingTreeView-innerMain').render(from('inner').map((v) -> WrappedVarying.hijack(v) if v?)).context('tree')
    find('.varyingTreeView-next').render(from('parent').map((v) -> WrappedVarying.hijack(v) if v?)).context('tree')
    find('.varyingTreeView-nexts').render(from('parents').map((x) -> x?.map((v) -> WrappedVarying.hijack(v))))
      .context('linked').options( itemContext: 'tree' )
  )
)


class VaryingPanel extends Model.build(
    attribute('subscribed', attribute.Boolean)

    attribute('active_reaction', class extends attribute.Enum
      nullable: true
      values: -> this.model.watch('wrapped').flatMap((wv) -> wv.watch('reactions'))
      default: -> null
    )

    bind('wrapped', from('subject').map((varying) -> WrappedVarying.hijack(varying)))
  )

  _initialize: ->
    # create or destroy our own hollow observation:
    this.watch('subscribed').reactLater((subbed) =>
      if subbed
        this._observation = this.get('subject').react(->)
      else
        this._observation.stop()
    )

VaryingView = DomView.build($('
    <div class="varyingView panel hasSidebar">
      <div class="panel-toolbar">
        <ul class="varyingView-subscriptionToggle toggleSwitch">
          <li><div class="icon icon-plug"></div></li>
          <li class="switch"></li>
        </ul>
      </div>
      <div class="panel-title">
        <div class="varyingView-titleMain"/>
        <div class="panel-subtitle">
          <span class="panel-subtitleText"/>
          <div class="panel-subtitleClose"><span class="icon"/></div>
        </div>
      </div>
      <div class="panel-main">
        <div class="varyingView-tree"/>
      </div>
      <div class="panel-sidebar varyingView-reactions"></div>
    </div>
  '), template(

    find('.varyingView-titleMain').text(from('wrapped').watch('title'))

    find('.varyingView-subscriptionToggle').classed('checked', from('subscribed'))
    find('.varyingView-subscriptionToggle .switch').render(from.attribute('subscribed'))
      .context('edit').criteria( attributes: { style: 'button' } )

    find('.varyingView-tree').render(from('wrapped').and('active_reaction').all.flatMap((wv, ar) ->
      if ar? then wv.watch('id').flatMap((id) -> ar.watch("tree.#{id}")) else wv
    )).context('tree')

    find('.varyingView-reactions').render(from.attribute('active_reaction'))
      .context('edit').criteria( attributes: { style: 'list' } )
      .options(from('wrapped').map((wv) -> { renderItem: (x) -> x.options( settings: { target: wv } ) }))

    find('.panel-subtitle').classed('hide', from('active_reaction').map((ar) -> !ar?))
    find('.panel-subtitleText').text(from('active_reaction').watch('root').watch('id').map((id) -> "Reaction @##{id}"))

    find('.panel-subtitleClose').on('click', (_, subject) => subject.unset('active_reaction'))
  ), { viewModelClass: VaryingPanel }
)


module.exports = {
  VaryingDebugView
  VaryingDeltaView
  VaryingTreeView
  VaryingView

  registerWith: (library) ->
    library.register(Varying, VaryingDebugView, context: 'debug')
    library.register(WrappedVarying, VaryingDeltaView, context: 'delta')
    library.register(WrappedVarying, VaryingTreeView, context: 'tree')
    library.register(Varying, VaryingView, context: 'panel')
}

