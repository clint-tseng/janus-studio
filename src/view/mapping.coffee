{ Model, bind, Varying, DomView, template, from, List } = require('janus')
$ = require('jquery')

{ WrappedVarying } = require('../model/wrapped-varying')
find = require('./mutators')
exec = require('../util/exec')
{ getArguments, deindent } = require('../util/util')


class Argument extends Model

ArgumentView = DomView.build($('
    <div class="argument">
      <span class="argument-name"/>
      <span class="argument-equals">=</span>
      <span class="argument-value"/>
    </div>
  '), template(
    find('.argument-name').text(from('name'))
    find('.argument-value').render(from('value')).context('debug')
  )
)

valueOf = (v) ->
  wrapped = WrappedVarying.hijack(v)
  wrapped.get('new_value') ? wrapped.get('value') ? wrapped.get('immediate')
watchValueOf = (v) ->
  wrapped = WrappedVarying.hijack(v)
  Varying.mapAll(((nv, v, i) -> nv ? v ? i), wrapped.watch('new_value'), wrapped.watch('value'), wrapped.watch('immediate'))

class Mapping extends Model.build(
    bind('applicants', from('subject').watch('parent').and('subject').watch('parents')
      .all.map((p, ps) -> ps ? new List(p)))

    bind('arguments.values', from('applicants').map((vs) -> vs.flatMap(watchValueOf)))

    bind('arguments.objs', from('arguments.names').and('arguments.values').all.flatMap((names, values) ->
      names.enumeration().flatMapPairs((idx, name) ->
        values.watchAt(idx).map((value) -> new Argument({ name, value })))
    ))
  )

  _initialize: ->
    varying = this.get('subject').get('target')
    this.set('mapping', varying._f)
    this.set('arguments.names', new List(getArguments(varying._f)))

MappingView = DomView.withOptions({ viewModelClass: Mapping }).build($('
    <div class="mapping">
      <div class="mapping-toolbar">
        <div class="mapping-debug" title="Step debug with these arguments" />
      </div>
      <div class="mapping-function">
        <div class="mapping-arguments"/>
        <pre/>
      </div>
      <div class="mapping-result">
        <div class="arrow"/>
        <div class="content"/>
      </div>
    </div>
  '), template(

    find('.mapping-function pre').text(from('mapping').map((f) -> deindent(f.toString()) if f?))

    find('.mapping-arguments')
      .classed('inline', from('arguments.objs').flatMap((aos) -> aos.watchLength().map((l) -> l < 4)))
      .render(from('arguments.objs'))

    find('.mapping-result .content').render(from('subject')).context('delta')

    find('.mapping-debug').on('click', (_, subject) ->
      wrapped = this.subject.get('subject')
      if (parents = wrapped.get('parents'))?
        exec(wrapped.get('target')._f, (valueOf(v) for v in parents.list))
      else if (parent = wrapped.get('parent'))?
        exec(wrapped.get('target')._f, [ valueOf(parent) ])
    )
  )
)


module.exports = {
  Argument
  ArgumentView
  Mapping
  MappingView

  registerWith: (library) ->
    library.register(Argument, ArgumentView)
    library.register(WrappedVarying, MappingView, context: 'mapping')
}

