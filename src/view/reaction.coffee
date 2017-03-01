{ DomView, template, find, from } = require('janus')
$ = require('jquery')
moment = require('moment')

{ Reaction, ReactionStep } = require('../model/reaction')


class ReactionStepView extends DomView
  @_dom: -> $('
    <div class="reactionStep">
      <div class="oldValue"/>
      <div class="separator"/>
      <div class="newValue"/>
    </div>
  ')
  @_template: template(
    find('.oldValue').render(from('oldValue')).context('debug')
    find('.newValue').render(from('newValue')).context('debug')
  )

class ReactionView extends DomView
  @_dom: -> $('
    <div class="reaction">
      <div class="upper">
        <div class="uid"/>
        <div class="time"/>
      </div>
      <div class="lower">
        <div class="root"/>
        <div class="changes">
          <span class="icon"/>
          <span class="count"/>
        </div>
      </div>
    </div>
  ')
  @_template: template(
    find('.uid').text(from('steps').flatMap((steps) -> steps.watchAt(0)).watch('target').watch('id').map((id) -> "##{id}"))
    find('.root').render(from('steps').map((steps) -> steps.watchAt(0)))

    find('.time').text(from('at').map((t) -> moment(t).format("HH:mm:ss.SS")))
    find('.changes .count').text(from('steps').flatMap((steps) -> steps.watchLength()))
  )

  _wireEvents: ->
    dom = this.artifact()
    global = this.options.app.get('global')
    subject = this.subject

    dom.on('mouseover', ->
      unless global.get('hover')?
        dom.one('mouseout', -> global.unset('hover'))
        global.set('hover', subject)
    )


module.exports = {
  ReactionStepView,
  ReactionView,
  registerWith: (library) ->
    library.register(ReactionStep, ReactionStepView)
    library.register(Reaction, ReactionView)
}

