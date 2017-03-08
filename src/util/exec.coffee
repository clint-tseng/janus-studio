
exec = (f, args) ->
  require('electron').remote.getCurrentWindow().openDevTools()

  `// step in (F11) to debug`
  debugger
  f.apply(null, args)

module.exports = exec

