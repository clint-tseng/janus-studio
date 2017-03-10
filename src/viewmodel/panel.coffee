{ Model, from } = require('janus')

class Panel extends Model
  constructor: (context, fixture) -> super({ context, fixture })

  @bind('id', from('fixture').watch('id'))

module.exports = { Panel }

