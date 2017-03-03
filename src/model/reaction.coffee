{ Model, List, attribute } = require('janus')


class Reaction extends Model
  isReaction: true

  @attribute('active', class extends attribute.BooleanAttribute
    default: -> true
  )
  @attribute('steps', class extends attribute.CollectionAttribute
    default: -> new List()
  )

  _initialize: ->
    this.set('at', new Date())

  logStep: (wrappedVarying, newValue, oldValue) ->
    step = new ReactionStep({ target: wrappedVarying, newValue, oldValue })
    this.set("lookup.#{wrappedVarying.get('id')}", step)
    this.get('steps').add(step)

class ReactionStep extends Model


module.exports = { Reaction, ReactionStep }

