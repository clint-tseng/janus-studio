{ Model, List, DomView, template, find, from } = require('janus')

$ = require('jquery')


# these classes are mostly to facilitate the treeviews involved with rendering
# varying debug information.

class LinkedListNode extends Model
  constructor: (list, idx) -> super({ list, idx })
  @bind('next', from('list').and('idx').all.flatMap((list, idx) ->
    list.watchLength().map((length) -> new LinkedListNode(list, idx + 1) if length > (idx + 1))
  ))

class LinkedListNodeView extends DomView
  @_dom: -> $('
    <div class="linkedList-node">
      <div class="linkedList-next"/>
      <div class="linkedList-contents"/>
    </div>
  ')
  @_template: template(
    find('.linkedList-contents')
      .render(from('list').and('idx').all.flatMap((list, idx) -> list.watchAt(idx)))
      .context(from.self().map((v) -> v.options.itemContext))

    find('.linkedList-next')
      .render(from('next'))
      .options(from.self().map((v) -> { itemContext: v.options.itemContext }))

    find('.linkedList-next').classed('hasNext', from('next').map((x) -> x?))
  )

class LinkedListView extends DomView
  @_dom: -> $('<div class="linkedList"/>')
  @_template: template(
    find('.linkedList')
      .render(from.self().flatMap((v) -> new LinkedListNode(v.subject, 0)))
      .options(from.self().map((v) -> { itemContext: v.options.itemContext }))
  )


module.exports = {
  LinkedListNode
  LinkedListNodeView
  LinkedListView

  registerWith: (library) ->
    library.register(LinkedListNode, LinkedListNodeView)
    library.register(List, LinkedListView, context: 'linked')
}

