{ Model, attribute, List, Set, Varying } = require('janus')

# for testing purposes, initially all fixtures are arbitrary code.
class Fixture extends Model
  # parameters contains the context-unique-id of each dependency.
  @attribute('parameters', class extends attribute.CollectionAttribute
    default: -> new List()
  )

  @attribute('code', class extends attribute.TextAttribute)

class Fixtures extends Set
  @modelClass: Fixture


module.exports = { Fixture, Fixtures }

