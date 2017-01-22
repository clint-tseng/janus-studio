{ DomView, template, find, from } = require('janus')

$ = require('jquery')

class IconView extends DomView
  @_dom: -> $('<span class="icon"/>')
  @_template: template(find('span').classGroup('icon-', from.self().map((x) -> x.subject)))

module.exports = {
  IconView,
  registerWith: (library) -> library.register(String, IconView, context: 'icon')
}

