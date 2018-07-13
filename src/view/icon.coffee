{ DomView, template, find, from } = require('janus')

$ = require('jquery')

IconView = DomView.build($('<span class="icon"/>'), template(
  find('span').classGroup('icon-', from.self().map((x) -> x.subject))
))

module.exports = {
  IconView,
  registerWith: (library) -> library.register(String, IconView, context: 'icon')
}

