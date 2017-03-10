{ Model, attribute, Varying, List } = require('janus')

pct = (x) -> "#{x}%"
px = (x) -> "#{x}px"

class Layout extends Model
  constructor: (context) -> super({ context })

  compute: ->
    this.watch('context').flatMap((context) ->
      Varying.flatMapAll(context.watch('layout.expanded'), context.watch('panels'), (expanded = new List(), panels) ->
        Varying.flatMapAll(expanded.watchLength(), panels.watchLength(), (numExpanded, numPanels) ->
          # for now watching for length changes is enough. eventually we should traverse or something.
          result = {}

          if numExpanded > 0
            numNonexpanded = numExpanded - numPanels

            expandHeight = (100 / numExpanded)
            expandWidth = if numNonexpanded > 0 then 75 else 100
            for id, idx in expanded.list
              result[id] = {
                left: pct(0), top: pct(expandHeight * idx),
                width: pct(75), height: pct(expandHeight)
              }

            idx = 0
            nonexpandHeight = 300
            for panel in panels.list when panel.get('id') not in expanded.list
              result[panel.get('id')] = {
                left: pct(75), top: pct(nonexpandHeight * idx),
                width: pct(25), height: px(nonexpandHeight)
              }
          else
            numColumns = if numPanels > 5 then 3 else 2
            columnWidth = 100 / numColumns
            panelsPerColumn = Math.ceil(numPanels / numColumns)

            lastColumn = numColumns - 1
            panelsPerLastColumn = numPanels - (panelsPerColumn * (numColumns - 1))

            for panel, idx in panels.list
              column = Math.floor(idx / panelsPerColumn)
              idxInColumn = idx % panelsPerColumn
              panelHeight = if column is lastColumn then (100 / panelsPerLastColumn) else (100 / panelsPerColumn)

              result[panel.get('id')] = {
                left: pct(columnWidth * column), top: pct(panelHeight * idxInColumn),
                width: pct(columnWidth), height: pct(panelHeight)
              }

          console.log(result)
          result
        )
      )
    )

module.exports = { Layout }

