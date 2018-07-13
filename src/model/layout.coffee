{ Model, attribute, bind, transient, from, Varying, List } = require('janus')

pct = (x) -> "#{x}%"
px = (x) -> "#{x}px"

Layout = Model.build(
  attribute('minimized', class extends attribute.Collection
    default: -> new List()
  )
  attribute('maximized', class extends attribute.Collection
    default: -> new List()
  )

  transient('computed')
  bind('computed', from('context').and('context').watch('panels').and('maximized').and('minimized').all.flatMap((context, panels, maximized, minimized) ->
    return {} unless context? and panels?

    Varying.flatMapAll(maximized.watchLength(), minimized.watchLength(), panels.watchLength(), (numMaximized, numMinimized, numPanels) ->
      # for now watching for length changes is enough. eventually we should traverse or something.
      result = {}

      if numMinimized > 0
        idx = 0
        minimizedWidth = Math.min(25, 100 / numMinimized)
        for panel in panels.list when panel.get('id') in minimized.list
          result[panel.get('id')] = {
            left: pct(minimizedWidth * idx), top: '', # top is overridden for minimized tabs.
            width: pct(minimizedWidth), height: '' # height is overridden for minimized tabs.
          }
          idx += 1

      if numMaximized > 0
        numNonmaximized = numPanels - numMinimized - numMaximized

        expandHeight = (100 / numMaximized)
        expandWidth = if numNonmaximized > 0 then 65 else 100
        for id, idx in maximized.list
          result[id] = {
            left: pct(0), top: pct(expandHeight * idx),
            width: pct(expandWidth), height: pct(expandHeight)
          }

        idx = 0
        nonexpandHeight = 300
        for panel in panels.list when panel.get('id') not in maximized.list and panel.get('id') not in minimized.list
          result[panel.get('id')] = {
            left: pct(65), top: px(nonexpandHeight * idx),
            width: pct(35), height: px(nonexpandHeight)
          }
          idx += 1
      else
        numColumns = if numPanels > 5 then 3 else 2
        columnWidth = 100 / numColumns
        panelsPerColumn = Math.ceil(numPanels / numColumns)

        lastColumn = numColumns - 1
        panelsPerLastColumn = numPanels - (panelsPerColumn * (numColumns - 1))

        idx = 0
        for panel in panels.list when panel.get('id') not in minimized.list
          column = Math.floor(idx / panelsPerColumn)
          idxInColumn = idx % panelsPerColumn
          panelHeight = if column is lastColumn then (100 / panelsPerLastColumn) else (100 / panelsPerColumn)

          result[panel.get('id')] = {
            left: pct(columnWidth * column), top: pct(panelHeight * idxInColumn),
            width: pct(columnWidth), height: pct(panelHeight)
          }
          idx += 1

      result
    )
  ))
)


module.exports = { Layout }

