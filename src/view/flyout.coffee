{ Model, bind, DomView, template, find, from } = require('janus')
{ sticky } = require('janus-stdlib').util.varying
$ = require('jquery')

class Flyout extends Model.build(
    bind('active', from('hover.trigger').and('hover.self').all.map((t, s) -> (t is true) or (s is true)))
    bind('delayed_active', from('active').pipe(sticky( true: 250 )))
    bind('subject', from('subject_varying').flatMap((x) -> x)) # errr should we have a .flatten()?
  )

  trigger: ->
    this.set('hover.trigger', true)
    this.get('trigger').one('mouseleave', => this.set('hover.trigger', false))

class FlyoutView extends DomView.build($('
    <div class="flyout">
      <div class="flyout-contents"/>
      <div class="flyout-marker"/>
    </div>
  '), template(
    find('.flyout-contents').render(from('subject'))
      .context(from('args.context'))
      .criteria(from('args.criteria'))
      .options(from('args.options'))

    find('.flyout-marker')
      .classGroup('side-', from('side'))
      .css('top', from('voffset').map((x) -> "#{x}px"))

    find('.flyout')
      .on('mouseenter', (_, flyout) => flyout.set('hover.self', true))
      .on('mouseleave', (_, flyout) => flyout.set('hover.self', false))
  ))

  _wireEvents: ->
    dom = this.artifact()
    flyout = this.subject
    trigger = flyout.get('trigger')
    wrapper = flyout.get('wrapper')
    body = $('body')

    this.subject.watch('delayed_active').reactLater((show) =>
      if show is true
        body.append(dom)

        offset = trigger.offset()
        dom.css('left', offset.left + trigger.outerWidth())
        dom.css('top', offset.top)

        flyout.set('side', 'left')
        flyout.set('voffset', 0)

        this.emit('appended')
      else
        wrapper.append(dom)
    )

module.exports = {
  Flyout,
  FlyoutView,

  registerWith: (library) -> library.register(Flyout, FlyoutView)
}

