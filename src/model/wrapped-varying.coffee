{ Model, attribute, List, from, Varying } = require('janus')
{ fix, uniqueId } = require('janus').util

{ Reaction, ReactionStep } = require('./reaction')


class WrappedVarying extends Model
  constructor: (@varying) ->
    super({
      id: uniqueId()
      target: this.varying
      title: this.varying.constructor.name

      flattened: this.varying._flatten is true
      mapped: this.varying._f?

      # parent is filled if this is mapped; parents if it is composed.
      parent: this.varying._parent
      parents: (new List(this.varying._applicants) if this.varying._applicants?)
    })

  _initialize: ->
    self = this
    varying = this.varying

    # OBSERVATION TRACKING:
    # grab the current set of observations, populate.
    observations = new List()
    addObservation = (observation) =>
      oldStop = observation.stop
      observation.stop = -> observations.remove(this); oldStop.call(this)
      observations.add(observation)
    addObservation(r) for r of varying._observers
    self.set('observations', observations)

    # hijack the react method:
    if (_react = varying._react)?
      varying._react = (f_, immediate) ->
        observation = _react.call(varying, f_, immediate)
        addObservation(observation)
        observation
    else
      varying.react = (f_) ->
        observation = Varying.prototype.react.call(varying, f_)
        addObservation(observation)
        observation

    # REACTION TRACKING:
    # listen to our parent's reactions if we've got one.
    self._trackReactions(WrappedVarying.hijack(varying._parent)) if varying._parent?

    # VALUE TRACKING:
    # grab the current value, populate.
    self.set('_value', varying._value)

    # for primitive varyings, hijack the set method to set a current value and
    # record a Reaction.
    if (_set = varying.set)?
      varying.set = (value) ->
        rxn = new Reaction( caller: arguments.callee.caller )
        self.get('reactions').add(rxn)
        rxn.logStep(self, value, self.get('value'))

        self.set('_value', value)

        _set.call(this, value)
        rxn.set('active', false)
        null

    # for derived varyings, hijack the _onValue method instead.
    if (_onValue = varying._onValue)?
      varying._onValue = (observation, value, silent) ->
        if (extantRxn = self.get('active_reactions').at(0))?
          extantRxn.logStep(self, value, self.get('value'), observation isnt varying._parentObservation)
        else
          # nothing has been set, but by virtue of a new observation we are now
          # computing what was previously not. create a reaction.
          newRxn = new Reaction( caller: arguments.callee.caller )
          self.get('reactions').add(newRxn)
          newRxn.logStep(self, value, self.get('value'))

          # TODO: should never happen; remove once we're sure we've made that true.
          #console.error('Tried to log a reaction step but no active reaction was found.', self, value)

        if varying._flatten is true
          if observation is varying._parentObservation
            # we have a potentially new value at the top level; change what we are tracking.
            self._untrackReactions(oldInner._wrapper) if (oldInner = self.get('inner'))?

            if value?.isVarying is true
              self.set('inner', value)
              self._trackReactions(WrappedVarying.hijack(value))
            else
              self.unset('inner')
          else
            # do things for inner value changing??
            null

        self.unset('immediate')
        self.set('_value', value)

        _onValue.call(varying, observation, value, silent)
        newRxn?.set('active', false)

    # hijack the immediate method:
    if (_immediate = varying._immediate)?
      varying._immediate = ->
        result = _immediate.call(varying)
        if result?.isVarying and varying._flatten is true
          self.set('inner', result)
          self.set('immediate', result.get()) # TODO: messy; not the actual result value instance
        else
          self.set('immediate', result)
        result

    # DIRECT ACTIVATION:
    # create or destroy our own hollow observation:
    self.watch('subscribed').react((subbed) ->
      if subbed
        self._observation = varying.reactNow(->)
      else
        self._observation.stop()
    )

  @attribute('subscribed', attribute.BooleanAttribute)
  @attribute('observations', attribute.CollectionAttribute)

  @attribute('reactions', class extends attribute.CollectionAttribute
    default: -> new List()
  )

  @bind('derived', from('mapped').and('flattened').all.map((m, f) -> m or f))
  @bind('value', from('_value').map((x) -> if x?.isNothing is true then null else x))

  @bind('active_reactions', from('reactions').map((rxns) -> rxns.filter((rxn) -> rxn.watch('active'))))

  # for now, naively assume this is the only cross-WV listener to simplify tracking.
  _trackReactions: (other) -> this.listenTo(other.get('reactions'), 'added', (r) => this.get('reactions').add(r))
  _untrackReactions: (other) -> this.unlistenTo(other)

  @hijack: (varying) -> varying._wrapper ?= new WrappedVarying(varying)

module.exports = { WrappedVarying }

