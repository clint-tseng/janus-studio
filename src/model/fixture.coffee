{ Model, attribute, List, Set, Varying } = require('janus')

# for testing purposes, initially all fixtures are arbitrary code.
Fixture = Model.build(
  # parameters contains the context-unique-id of each dependency.
  attribute('parameters', class extends attribute.Collection
    default: -> new List()
  )

  attribute('code', class extends attribute.Text)
)

Fixtures = Set.of(Fixture)


module.exports = { Fixture, Fixtures }

