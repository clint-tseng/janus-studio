{ Model, attribute, List, Varying } = require('janus')

# for testing purposes, initially all fixtures are arbitrary code.
class Fixture extends Model
  # parameters contains the context-unique-id of each dependency.
  @attribute('parameters', class extends attribute.CollectionAttribute
    default: -> new List()
  )

class Fixtures extends List
  @modelClass: Fixture


module.exports = { Fixture, Fixtures }

