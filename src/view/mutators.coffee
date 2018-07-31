{ Varying, find, from, mutators } = require('janus')
$ = require('jquery')

{ Flyout } = require('../view/flyout')

customMutators = {
  flyout: (data, args = {}) ->
    result = (dom, point) ->
      wrapper = $('<div/>')
      flyout = new Flyout({ trigger: dom, wrapper, subject_varying: data.all.point(point), args })
      mutator = mutators.render(from(new Varying(flyout)))(wrapper, point)

      if (oldFlyout = dom.data('flyout'))?
        dom.off('mouseenter.flyout')
        oldFlyout.destroy()

      dom.data('flyout', flyout)
      rawDom = dom.get(0)
      dom.on('mouseenter.flyout', -> flyout.trigger()) # TODO: is this better done in some wireEvents? which?
      mutator

    result.context = (context) -> customMutators.flyout(data, Object.assign({}, args, { context }))
    result.criteria = (criteria) -> customMutators.flyout(data, Object.assign({}, args, { criteria }))
    result.options = (options) -> customMutators.flyout(data, Object.assign({}, args, { options }))
    result
}

module.exports = find.build(Object.assign({}, mutators, customMutators))

