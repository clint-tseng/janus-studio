{ DomView, template, find, from } = require('janus')
{ isPrimitive, isArray } = require('janus').util

$ = require('jquery')

LiteralView = DomView.build($('<span class="janus-literal"/>'), template(
  find('span').text(from((x) ->
    if isPrimitive(x) or isArray(x)
      JSON.stringify(x)
    else
      x
  ))
))

NullView = DomView.build($('<span class="janus-literal janus-null">Ø</span>'), template(
  find('span').attr('title', from((x) -> "#{x}"))
))

module.exports = {
  LiteralView,
  registerWith: (library) ->
    library.register(String, LiteralView, context: 'debug')
    library.register(Number, LiteralView, context: 'debug')
    library.register(Boolean, LiteralView, context: 'debug')
    library.register(null, NullView, context: 'debug')
}

