{ DomView, template, find, from } = require('janus')
$ = require('jquery')
moment = require('moment')

{ Reaction } = require('../model/wrapped-varying')


class ReactionView extends DomView
  @_dom: -> $('
    <div class="reaction">
      <div class="upper">
        <div class="uid"/>
        <div class="time"/>
      </div>
      <div class="lower">
        <div class="root"/>
      </div>
    </div>
  ')
  @_template: template(
    find('.uid').text(from('root').watch('id').map((id) -> "##{id}"))
    find('.time').text(from('at').map((t) -> moment(t).format("HH:mm:ss.SS")))
  )


module.exports = {
  ReactionView,
  registerWith: (library) -> library.register(Reaction, ReactionView)
}

