{ Model, DomView, template, find, from } = require('janus')
{ sticky } = require('janus-stdlib').util.varying
$ = require('jquery')

class Flyout extends Model
  @bind('active', from('hover.trigger').and('hover.self').all.map((t, s) -> (t is true) or (s is true)))
  @bind('delayed_active', from.self().flatMap((self) -> sticky(self.watch('active'), true: 250)))
  @bind('subject', from('subject_varying').flatMap((x) -> x))

  trigger: ->
    this.set('hover.trigger', true)
    this.get('trigger').one('mouseleave', => this.set('hover.trigger', false))

class FlyoutView extends DomView
  @_dom: -> $('
    <div class="flyout">
      <div class="flyout-contents"/>
      <div class="flyout-marker"/>
    </div>
  ')
  @_template: template(
    find('.flyout-contents').render(from('subject'))
      .context(from('args.context'))
      .find(from('args.find'))
      .options(from('args.options'))

    find('.flyout-marker').classGroup('side-', from('side'))
    find('.flyout-marker').css('top', from('voffset').map((x) -> "#{x}px"))
  )

  _wireEvents: ->
    dom = this.artifact()
    flyout = this.subject
    trigger = flyout.get('trigger')
    wrapper = flyout.get('wrapper')
    body = $('body')

    this.subject.watch('delayed_active').react((show) =>
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

    dom.on('mouseenter', -> flyout.set('hover.self', true))
    dom.on('mouseleave', -> flyout.set('hover.self', false))

module.exports = {
  Flyout,
  FlyoutView,

  registerWith: (library) -> library.register(Flyout, FlyoutView)
}

