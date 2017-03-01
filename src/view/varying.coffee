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

    find('.value').render(from('immediate').and('value').and('id').and.app().watch('global').watch('hover')
      .all.flatMap((immediate, value, id, hover) ->
        if hover?.isReaction is true
          hover.watch('steps').flatMap((steps) ->
            Varying.managed(
              (-> steps.filter((step) -> step.watch('target').flatMap((target) -> target.watch('id').map((tid) -> tid is id)))),
              ((matches) -> matches.watchLength().map((ml) -> if ml is 0 then immediate ? value else matches))
            )
          )
        else
          immediate ? value
      )).context('debug')

    find('.mapping').attr('title', from('target').map((varying) -> varying._f))

    find('.varyingTreeView-inner').render(from('inner').map((v) -> WrappedVarying.hijack(v) if v?)).context('debug-tree')
    find('.varyingTreeView-next').render(from('parent').map((v) -> WrappedVarying.hijack(v) if v?)).context('debug-tree')
    find('.varyingTreeView-nexts').render(from('parents').map((x) -> x?.map((v) -> WrappedVarying.hijack(v))))
      .context('linked').options( itemContext: 'debug-tree' )
  )

class VaryingView extends DomView
  # we want something of a viewmodel, but one that's not constructed the standard way, so override:
  constructor: (varying, options) -> super(WrappedVarying.hijack(varying), options)

  @_dom: -> $('
    <div class="varyingView panel hasSidebar">
      <div class="panel-toolbar">
        <ul class="varyingView-subscriptionToggle toggleSwitch">
          <li><div class="icon icon-plug"></div></li>
          <li class="switch"></li>
        </ul>
      </div>
      <div class="panel-title"></div>
      <div class="panel-main varyingView-tree"></div>
      <div class="panel-sidebar varyingView-reactions"></div>
    </div>
  ')
  @_template: template(
    find('.panel-title').text(from('title'))

    find('.varyingView-subscriptionToggle').classed('checked', from('subscribed'))
    find('.varyingView-subscriptionToggle .switch').render(from.attribute('subscribed'))
      .context('edit').find( attributes: { style: 'button' } )
    find('.varyingView-tree').render(from.self((v) -> v.subject)).context('debug-tree')

    find('.varyingView-reactions').render(from('reactions'))
  )

module.exports = {
  VaryingView
  VaryingTreeView

  registerWith: (library) ->
    library.register(Varying, VaryingDebugView, context: 'debug')
    library.register(WrappedVarying, VaryingTreeView, context: 'debug-tree')
    library.register(Varying, VaryingView, context: 'debug-pane')
}

