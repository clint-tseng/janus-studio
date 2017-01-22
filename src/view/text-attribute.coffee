{ TextAttribute } = require('janus').attribute
{ TextAttributeEditView } = require('janus-stdlib').view.textAttribute
{ extendNew } = require('janus').util

class KVEditView extends TextAttributeEditView
  constructor: (subject, options) -> super(subject, extendNew(options, update: 'n/a'))

  _wireEvents: ->
    super()
    input = this.artifact()

    input.on('keydown', (event) =>
      if event.which is 13 # enter
        input.blur()
        this.subject.setValue(input.val())
      else if event.which is 27 # esc
        input.blur()
        input.val(this.subject.getValue())
    )

module.exports = {
  KVEditView,
  registerWith: (library) -> library.register(TextAttribute, KVEditView, context: 'edit', attributes: { commit: 'hard' })
}

