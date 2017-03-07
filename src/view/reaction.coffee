{ Model, DomView, template, find, from } = require('janus')
$ = require('jquery')
moment = require('moment')

{ Reaction } = require('../model/wrapped-varying')


class ReactionVM extends Model
  @bind('at', from('subject').watch('at').map(moment))
  @bind('change_count', from('subject').watch('changes').flatMap((cs) -> cs.watchLength()))
  @bind('target', from('settings.target').and('subject').all.flatMap((target, subject) ->
    if target?
      subject.watchNode(target)
    else
      subject.watch('changes').flatMap((cs) -> cs.watchAt(-1))
  ))
  @bind('root', from('target').and('subject').watch('root').all.map((t, r) -> r unless t is r))

class ReactionView extends DomView
  @viewModelClass: ReactionVM

  @_dom: -> $('
    <div class="reaction">
      <div class="time"><span class="minor"/><span class="major"/></div>

      <div class="reaction-part reaction-inspectionTarget">
        <div class="reaction-part-id"/>
        <div class="reaction-part-delta"/>
      </div>
      <div class="reaction-intermediate">
        <span class="ellipsis">&vellip;</span>
        <span class="multiple">&times;<span class="count"/></span>
      </div>
      <div class="reaction-part reaction-root">
        <div class="reaction-part-id"/>
        <div class="reaction-part-delta"/>
      </div>
    </div>
  ')
  @_template: template(
    find('.time .minor').text(from('at').map((t) -> t.format("HH:mm:")))
    find('.time .major').text(from('at').map((t) -> t.format("ss.SS")))

    find('.reaction-inspectionTarget .reaction-part-id').text(from('target').watch('id').map((id) -> "##{id}"))
    find('.reaction-inspectionTarget .reaction-part-delta').render(from('target')).context('delta')

    find('.reaction-intermediate').classed('hide', from('change_count').map((x) -> x < 3))
    find('.reaction-intermediate .count').text(from('change_count').map((cc) -> cc - 2))

    find('.reaction-root').classed('hide', from('root').map((r) -> !r?))
    find('.reaction-root .reaction-part-id').text(from('root').watch('id').map((id) -> "##{id}"))
    find('.reaction-root .reaction-part-delta').render(from('root')).context('delta')
  )


module.exports = {
  ReactionView,
  registerWith: (library) -> library.register(Reaction, ReactionView)
}

